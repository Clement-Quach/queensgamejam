extends Node2D
@onready var levelUp = preload("res://scenes/level_up_orb.tscn")
var spawn_interval_min = 2.0
var spawn_interval_max = 4.0
@onready var playerLevel = $player/leveling
@onready var levelLabel = $level/Label
@onready var levelBar = $level/ProgressBar
@onready var enemy_scene = preload("res://scenes/enemy.tscn")
@export var initial_enemy_count: int = 3       # starting number of enemies per wave
@export var enemy_wave_increment: int = 2      # additional enemies per wave
@export var spawn_delay: float = 0.5           # delay between spawning each enemy
@export var wave_delay: float = 5.0
@export var laser_despawn_delay = 1
@export var laser_delay = .7
var current_wave: int = 1
var current_enemy_count: int = initial_enemy_count
@export var boss1: PackedScene 
var boss1Spawned = false

@onready var boss2 = preload("res://scenes/worm_boss.tscn")
var boss2Spawned = false

@onready var laser_scene = preload("res://scenes/laser.tscn")
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	start_spawning()
	start_waves()
	$bossTimer.timeout.connect(uraniumBoss)
	$bossTimer.start()
	$bossTimer2.timeout.connect(wormBoss)
	$bossTimer2.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	levelLabel.text = str(playerLevel.level)
	fillBar()

func update_progress_bar(target_value: float, duration: float) -> void:
	# Create a tween that will smoothly interpolate the progress bar's value.
	var tween = get_tree().create_tween()
	tween.tween_property(levelBar, "value", target_value, duration)


func fillBar():
	levelBar.max_value = playerLevel.toNextLevel
	update_progress_bar(playerLevel.levelPts, 0.25)

func spawn_lasers() -> void:
	while true:
		var laser_instance = laser_scene.instantiate()
		var side = rng.randi() % 4
		laser_instance.position = get_laser_spawn_position(side)
		match side:
			0:
				laser_instance.rotation = rng.randf_range(-PI/4,PI/4)
			1:
				laser_instance.rotation = rng.randf_range(PI/4,3*PI/4)
			2:
				laser_instance.rotation = rng.randf_range(PI,2*PI)
			3:
				laser_instance.rotation = rng.randf_range(0,PI)
		add_child(laser_instance)
		await get_tree().create_timer(laser_despawn_delay).timeout
		laser_instance.queue_free()
		await get_tree().create_timer(laser_delay).timeout
		

func get_laser_spawn_position(side) -> Vector2:
	var viewport_rect = get_viewport().get_visible_rect()
	var pos = Vector2.ZERO
# 0=left, 1=right, 2=top, 3=bottom
	match side:
		0:  # Left side
			pos.x = viewport_rect.position.x - 50
			pos.y = randf_range(viewport_rect.position.y, viewport_rect.position.y + viewport_rect.size.y)
		1:  # Right side
			pos.x = viewport_rect.position.x + viewport_rect.size.x + 50
			pos.y = randf_range(viewport_rect.position.y, viewport_rect.position.y + viewport_rect.size.y)
		2:  # Top side
			pos.y = viewport_rect.position.y - 50
			pos.x = randf_range(viewport_rect.position.x, viewport_rect.position.x + viewport_rect.size.x)
		3:  # Bottom side
			pos.y = viewport_rect.position.y + viewport_rect.size.y + 50
			pos.x = randf_range(viewport_rect.position.x, viewport_rect.position.x + viewport_rect.size.x)
	return pos
func spawn_waves() -> void:
	while true:
		print("Starting wave %d with %d enemies" % [current_wave, current_enemy_count])
		# Spawn enemies for the current wave
		for i in range(current_enemy_count):
			spawn_enemy()
			await get_tree().create_timer(spawn_delay).timeout
		# Wait before starting the next wave
		await get_tree().create_timer(wave_delay).timeout
		# Increase the wave and ramp up the enemy count
		current_wave += 1
		if current_wave % 2 == 0:
			current_enemy_count += enemy_wave_increment



############################### ENEMY SPAWNING #####################################################

func start_waves() -> void:
	# Use an infinite loop to continuously spawn waves
	spawn_waves()
	
func spawn_enemy() -> void:
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.position = get_spawn_position()
	add_child(enemy_instance)

func get_spawn_position() -> Vector2:
	var viewport_rect = get_viewport().get_visible_rect()
	var pos = Vector2.ZERO
	var side = randi() % 4  # 0=left, 1=right, 2=top, 3=bottom
	match side:
		0:  # Left side
			pos.x = viewport_rect.position.x - 50
			pos.y = randf_range(viewport_rect.position.y, viewport_rect.position.y + viewport_rect.size.y)
		1:  # Right side
			pos.x = viewport_rect.position.x + viewport_rect.size.x + 50
			pos.y = randf_range(viewport_rect.position.y, viewport_rect.position.y + viewport_rect.size.y)
		2:  # Top side
			pos.y = viewport_rect.position.y - 50
			pos.x = randf_range(viewport_rect.position.x, viewport_rect.position.x + viewport_rect.size.x)
		3:  # Bottom side
			pos.y = viewport_rect.position.y + viewport_rect.size.y + 50
			pos.x = randf_range(viewport_rect.position.x, viewport_rect.position.x + viewport_rect.size.x)
	return pos
####################################################################################################

################################## SPAWNING LEVELING ORBS ##########################################
func spawnLevelOrb():
	var s = levelUp.instantiate()
	add_child(s)
	s.scale.x = 0.25
	s.scale.y = 0.25
	s.position.x = randi_range(10, 900)
	s.position.y = randi_range(10, 500)

func start_spawning():
	while true:
		spawnLevelOrb()
		var wait_time = randf_range(spawn_interval_min, spawn_interval_max)
		await get_tree().create_timer(wait_time).timeout
		spawn_interval_min = max(0.5, spawn_interval_min - 0.05)
		spawn_interval_max = max(1.0, spawn_interval_max - 0.05)
####################################################################################################

func wormBoss() -> void:
	if boss2 and !boss2Spawned:
		$bossTimer2.paused =true
		var bossA = boss2.instantiate() as Node2D
		print(bossA)
		if bossA:
			print("gyat")
			# Set the position of the spawned object near the spawner
			add_child(bossA)  # Add to the same parent scene

#boss spawning
func uraniumBoss() -> void:
	if boss1 and !boss1Spawned:
		$bossTimer.paused =true
		var boss = boss1.instantiate() as CharacterBody2D
		print(boss)
		if boss:
			boss.position = Vector2(454,125)
			# Set the position of the spawned object near the spawner
			add_child(boss)  # Add to the same parent scene
