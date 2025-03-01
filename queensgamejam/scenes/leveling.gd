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
		print("level is currently: " + str(level))
		print("orbs needed till next level: " + str(toNextLevel))
	else:
		levelPts += 1
		print(levelPts)
		


func _on_pickup_area_area_entered(area: Area2D) -> void:
	levelUp()
	var h = area.get_parent()
	h.queue_free()
