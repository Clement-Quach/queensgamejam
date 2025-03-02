extends Node2D
var radius = 120
var angle = 0
var speed = 0
var rotationSpeed = 1
var center_offset = 0
var rng = RandomNumberGenerator.new()
var rotationMultiplier = rng.randf_range(-1.5,1.5)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	angle += rng.randf_range(1,2)*speed*delta
	rotation += rotationMultiplier*rotationSpeed*delta
	#set_rotation(rotation) 
	var x_pos = cos(angle)
	var y_pos = sin(angle)
	
	position.x = radius*x_pos
	position.y = radius*y_pos
	
