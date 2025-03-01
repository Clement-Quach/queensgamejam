extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func _on_play_button_down() -> void:
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://scenes/collider.tscn")
	



func _on_quit_button_down() -> void:
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()
