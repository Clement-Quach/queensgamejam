extends Node2D
@onready var levelUp = preload("res://scenes/level_up_orb.tscn")
var spawn_interval_min = 2.0
var spawn_interval_max = 4.0
@onready var playerLevel = $player/leveling
@onready var levelLabel = $level/Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_spawning()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	levelLabel.text = str(playerLevel.level)


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
