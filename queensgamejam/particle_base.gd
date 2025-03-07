extends CharacterBody2D

@export var friction: float = 0.98
@export var direction: Vector2
@export var mass: int = 1
@export var SPEED: float = 3
var augment1 = false
var augment2 = false
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
	if augment1 == true:
		var count = get_node("leveling").shieldCount
		SPEED =log(count)/log(10) + 3
	if augment2== true:
		friction = .99
		if Input.is_action_pressed("move_up"):
			direction.y -= SPEED
		if Input.is_action_pressed("move_down"):
			direction.y += SPEED
		if Input.is_action_pressed("move_left"):
			direction.x -= SPEED
		if Input.is_action_pressed("move_right"):
			direction.x += SPEED
			
		




func getMass() -> int:
	return mass
	
func getDirection() -> Vector2:
	return direction




func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:

	# Get the parent of the Area2D, which should be the other CharacterBody2D
	var other_body = area.get_parent()
	
	# Check if the parent is a CharacterBody2D
	if other_body is CharacterBody2D and other_body.has_method("getMass"):

		# Access the 'value' variable from the other CharacterBody2D
		var otherDirection = other_body.getDirection()
		var otherMass = other_body.getMass()
		await get_tree().create_timer(0).timeout
		
		direction = (((mass-otherMass)/(mass+otherMass)) * direction ) + (( 2*otherMass)/(mass+otherMass))*otherDirection
