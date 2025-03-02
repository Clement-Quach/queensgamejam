extends Node2D

func _ready() ->void:
	$AnimationPlayer.play("laser")
func _physics_process(delta: float) -> void:
	pass
		
func _on_area_2d_area_entered(area: Area2D) -> void:
	var playerNode = get_parent().get_node("player")
	print("hit")# Replace with function body.
