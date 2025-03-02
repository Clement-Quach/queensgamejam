extends CharacterBody2D

@export var friction: float = 0.995
@export var direction: Vector2
@export var mass: int = 1
@export var SPEED: float = 3
func _ready() -> void:
	#direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	direction = Vector2.ZERO
func _physics_process(delta: float) -> void:
	if is_on_wall():
		direction.x = direction.x * -1
	if is_on_floor() || is_on_ceiling():
		direction.y = direction.y * -1




	velocity.x = direction.x * SPEED
	velocity.y = direction.y * SPEED
	move_and_slide()
	#friction
	direction.x = direction.x * friction
	direction.y = direction.y * friction

func getMass() -> int:
	return mass
	
func getDirection() -> Vector2:
	return direction




func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print(name)
	# Get the parent of the Area2D, which should be the other CharacterBody2D
	var other_body = area.get_parent()
	
	# Check if the parent is a CharacterBody2D
	if other_body is CharacterBody2D:
		print(other_body.name, " ", other_body.direction)
		# Access the 'value' variable from the other CharacterBody2D
		var otherDirection = other_body.getDirection()
		var otherMass = other_body.getMass()
		await get_tree().create_timer(0).timeout
		
		direction = (((mass-otherMass)/(mass+otherMass)) * direction ) + (( 2*otherMass)/(mass+otherMass))*otherDirection


func _on_hurtbox_area_exited(area: Area2D) -> void:
	queue_free()
