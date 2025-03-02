extends CharacterBody2D
@export var speed: float
@export var direction: Vector2


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_on_floor() || is_on_wall():
		queue_free()
	
	#if collision with player
	
	velocity = direction * speed
	move_and_slide()




func _on_area_2d_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	print (parent.name)
	if  parent and parent.name == "player":
		parent.queue_free()
		
