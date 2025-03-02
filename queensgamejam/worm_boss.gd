extends Node2D

# Instead of exporting packed scenes, we reference our template nodes.
@onready var invuln_segment_template = $segment
@onready var dmg_segment_template = $segmentHurt
@export var segment_count: int = 5       # Total segments
@export var segment_distance: float = 70.0 # Distance between segments
@export var speed: float = 100.0           # Movement speed
@export var turn_interval: float = 2.0     # Time (in seconds) between setting a new target turn
@export var turn_speed: float = 2.0        # How fast the worm rotates (radians per second)
@export var vulnerability_interval: float = 3.0  # Vulnerable segment switch interval
@export var health: int = 20             # Boss health
@onready var levelUp = preload("res://scenes/level_up_orb.tscn")
@onready var healthLabel = $CanvasLayer/health/Label
@onready var healthBar = $CanvasLayer/health/ProgressBar
@onready var maxHealth = health
var dead = false

var screen_width: float = 454.0
var screen_height: float = 255.0

var segments: Array = []           # Holds our segment nodes
var vulnerable_index: int = -1     # Index of the current vulnerable segment

# Instead of only a vector direction, we now store angles.
var current_angle: float = 0.0
var target_angle: float = 0.0

var current_direction: Vector2 = Vector2.RIGHT  # This will be updated based on current_angle
var turn_timer: float = 0.0
var vulnerability_timer: float = 0.0
var elapsed_time: float = 0.0      # Drives the sine-wave wiggle

# Wiggle parameters
var wiggle_amplitude: float = 20.0
var wiggle_frequency: float = 3.0

func _ready() -> void:
	# Hide the template nodes (they are only for duplication)
	invuln_segment_template.hide()
	dmg_segment_template.hide()
	healthLabel.text = "PEPTIDE BONDS"	
	randomize()
	# Initialize angles (assuming starting direction is to the right)
	current_angle = 0.0
	target_angle = current_angle
	current_direction = Vector2.RIGHT
	
	# Create segments by duplicating the invulnerable template.
	for i in range(segment_count):
		var seg = invuln_segment_template.duplicate()
		seg.show()
		add_child(seg)
		segments.append(seg)
		seg.position = position - current_direction * (i * segment_distance)
	
	turn_timer = turn_interval
	vulnerability_timer = vulnerability_interval
	choose_new_vulnerable()

func _process(delta: float) -> void:
	fillBar()
	if health <= 0 and dead == false:
		dead = true
		$death.play()
		for i in 50:
			spawnLevelOrb()
		await get_tree().create_timer(0.32).timeout
		queue_free()
	elapsed_time += delta
	
	# Smoothly interpolate current_angle toward target_angle.
	current_angle = lerp_angle(current_angle, target_angle, turn_speed * delta)
	current_direction = Vector2(cos(current_angle), sin(current_angle))
	
	# Move the head.
	var move = current_direction * speed * delta
	position += move
	
	# Bounce off walls.
	bounce_off_walls()
	
	# Update segments positions so they follow the head.
	update_segments_positions()
	
	# Handle turning: when turn_timer expires, set a new target_angle.
	turn_timer -= delta
	if turn_timer <= 0:
		turn_timer = turn_interval
		# Add a random turn offset to the current_angle.
		target_angle = current_angle + randf_range(-PI/4, PI/4)
	
	# Vulnerability switching.
	vulnerability_timer -= delta
	if vulnerability_timer <= 0:
		vulnerability_timer = vulnerability_interval
		choose_new_vulnerable()

func bounce_off_walls() -> void:
	# Check and clamp the head's position.
	var bounced = false
	if position.x < 0:
		position.x = 0
		if current_direction.x < 0:
			# Reflect horizontally.
			current_direction.x = -current_direction.x
			bounced = true
	elif position.x > screen_width:
		position.x = screen_width
		if current_direction.x > 0:
			current_direction.x = -current_direction.x
			bounced = true
	
	if position.y < 0:
		position.y = 0
		if current_direction.y < 0:
			current_direction.y = -current_direction.y
			bounced = true
	elif position.y > screen_height:
		position.y = screen_height
		if current_direction.y > 0:
			current_direction.y = -current_direction.y
			bounced = true
	
	if bounced:
		# If a bounce occurs, update angles accordingly.
		current_angle = current_direction.angle()
		target_angle = current_angle

func update_segments_positions() -> void:
	# Position each segment relative to the head using the current_direction.
	for i in range(segments.size()):
		var base_pos = position - current_direction * (i * segment_distance)
		# Perpendicular vector for sine-wave wiggle.
		var perp = Vector2(-current_direction.y, current_direction.x)
		var offset = sin(elapsed_time * wiggle_frequency + i) * wiggle_amplitude
		segments[i].position = base_pos + perp * offset

func choose_new_vulnerable() -> void:
	# If a vulnerable segment already exists, revert it to invulnerable.
	if vulnerable_index != -1:
		var old_vuln = segments[vulnerable_index]
		var new_invuln = invuln_segment_template.duplicate()
		new_invuln.show()
		new_invuln.position = old_vuln.position
		add_child(new_invuln)
		segments[vulnerable_index] = new_invuln
		old_vuln.queue_free()
		
	# Choose a new random index for vulnerability.
	vulnerable_index = randi() % segments.size()
	var old_seg = segments[vulnerable_index]
	var new_vuln = dmg_segment_template.duplicate()
	new_vuln.show()
	new_vuln.position = old_seg.position
	add_child(new_vuln)
	segments[vulnerable_index] = new_vuln
	old_seg.queue_free()

func take_damage(amount: int) -> void:
	health -= amount
	$hit.play()


func _on_area_2d_body_entered(body: Node2D) -> void:
	take_damage(1)
	print("HIt")

func spawnLevelOrb():
	var s = levelUp.instantiate()
	get_parent().add_child(s)
	s.scale.x = 0.25
	s.scale.y = 0.25
	s.position.x = randi_range(-100,100 ) +self.position.x
	s.position.y = randi_range(0, 100) + self.position.y

func update_progress_bar(target_value: float, duration: float) -> void:
	# Create a tween that will smoothly interpolate the progress bar's value.
	var tween = get_tree().create_tween()
	tween.tween_property(healthBar, "value", target_value, duration)


func fillBar():
	healthBar.max_value = maxHealth
	update_progress_bar(health, 0.25)
