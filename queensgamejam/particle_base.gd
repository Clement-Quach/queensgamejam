extends CharacterBody2D

@export var direction: Vector2
@export var value: int = 1
@export var SPEED: int = 300

func _ready() -> void:
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))

func _physics_process(delta: float) -> void:
	if is_on_wall():
		direction.x = direction.x * -1
	if is_on_floor() || is_on_ceiling():
		direction.y = direction.y * -1

	if Input.is_action_just_pressed("ui_down"):
		shake()


	direction = direction.normalized()
	velocity.x = direction.x * SPEED
	velocity.y = direction.y * SPEED
	move_and_slide()
	
	
func shake():
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))

func _on_area_2d_area_entered(area: Area2D) -> void:
	# Get the parent of the Area2D, which should be the other CharacterBody2D
	var other_body = area.get_parent()
	
	# Check if the parent is a CharacterBody2D
	if other_body is CharacterBody2D:
		# Access the 'value' variable from the other CharacterBody2D
		var other_value = other_body.direction
		direction.x = (other_value.x +direction.x)/2
		direction.y = (other_value.y + direction.y)/2
