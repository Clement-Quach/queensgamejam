extends Node

var level : int = 1
var toNextLevel : int = 3
var levelPts : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func levelUp():
	if levelPts == toNextLevel:
		level += 1
		toNextLevel = round(toNextLevel * 1.5)
		levelPts = 0
		$"level up".play()
	else:
		levelPts += 1
		$collect.play()
		
func _exit_tree() -> void:
	# This code will run before the node is removed.
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	# You can trigger additional logic here.

func _on_pickup_area_area_entered(area: Area2D) -> void:
	levelUp()
	var h = area.get_parent()
	h.queue_free()
