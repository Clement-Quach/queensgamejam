extends CharacterBody2D

@onready var levelUp = preload("res://scenes/level_up_orb.tscn")
@export var health: int
@onready var maxHealth = health
@export var spawn_scene: PackedScene  # Assign the scene you want to spawn in the Inspector
@export var player:CharacterBody2D
@export var cooldown:bool
@onready var hitFlash = $hitFlash
@onready var healthLabel = $health/Label
@onready var healthBar = $health/ProgressBar

func _ready() -> void:
	# Example: Spawn every 3 seconds
	$shootTimer.timeout.connect(shoot)
	$shootTimer.start()
	$rainTimer.timeout.connect(rain)
	$rainTimer.start()
	$lockout.timeout.connect(lockout)
	$lockout.start()
	$coolDownPeriod.timeout.connect(uncooldown)
	cooldown = false
	player = get_parent().get_node("player")
	

	

func _physics_process(delta: float) -> void:
	healthLabel.text = "uranium 248"
	fillBar()
	#on death
	if health <= 0:
		for i in 50:
			spawnLevelOrb()
		
		queue_free()
	
func lockout() -> void:
	print("lockout")
	cooldown = true
	$coolDownPeriod.start()
	
	
func uncooldown() -> void:
	print("uncooldown")
	cooldown = false
	$coolDownPeriod.paused = true
	
func rain() -> void:
	spawn_character(Vector2(0,1),self.position + Vector2(randf_range(-300,300),-10), 200)

func shoot() -> void:
	if !cooldown :
		var fireTowards = (player.position - self.position).normalized()
		spawn_character(fireTowards, self.position + Vector2(0, 50), 300.0)



func _on_hurt_box_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	
	if parent is CharacterBody2D and parent.has_method("getMass"):
		health -= parent.getMass()
		print(health)
		hitFlash.play("hitFlash")
		

func spawnLevelOrb():
	var s = levelUp.instantiate()
	get_parent().add_child(s)
	s.scale.x = 0.25
	s.scale.y = 0.25
	s.position.x = randi_range(-100,100 ) +self.position.x
	s.position.y = randi_range(0, 100) + self.position.y


func spawn_character(dir:Vector2, location:Vector2, speed:float) -> void:
	if spawn_scene:
		var new_character = spawn_scene.instantiate() as CharacterBody2D
		if new_character:
			# Set the position of the spawned object near the spawner
			new_character.position = location
			new_character.direction = dir
			new_character.speed = speed
			get_parent().add_child(new_character)  # Add to the same parent scene
			

func update_progress_bar(target_value: float, duration: float) -> void:
	# Create a tween that will smoothly interpolate the progress bar's value.
	var tween = get_tree().create_tween()
	tween.tween_property(healthBar, "value", target_value, duration)


func fillBar():
	healthBar.max_value = maxHealth
	update_progress_bar(health, 0.25)
