extends Line2D

@export var max_length: float = 200  # Maximum length of the line in pixels

# Called when the node enters the scene tree for the first time.
var player
var vecStart := Vector2.ZERO
var vecEnd := Vector2.ZERO

func _ready() -> void:
	player = get_parent().get_node("player")

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		visible = true
		vecStart = get_global_mouse_position()
		vecEnd = vecStart

	if Input.is_action_pressed("click"):
		visible = true
		vecEnd = get_global_mouse_position()

		# Calculate the direction vector from start to end
		var dir = vecEnd - vecStart

		# If the length of the direction vector exceeds max_length, clamp it
		if dir.length() > max_length:
			dir = dir.normalized() * max_length
			vecEnd = vecStart + dir  # Update vecEnd to the clamped position

		# Update the line points
		points[0] = vecStart
		points[1] = vecEnd

	if Input.is_action_just_released("click"):
		visible = false
		var dir = vecStart - vecEnd

		# Clamp the length of the vector to the maximum length
		if dir.length() > max_length:
			dir = dir.normalized() * max_length

		player.direction = dir

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
