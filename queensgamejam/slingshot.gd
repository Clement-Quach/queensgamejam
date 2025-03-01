extends Line2D
@export var max = 100

# Called when the node enters the scene tree for the first time.
#might need to change this to an on ready function
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
		points[0] = vecStart
		points[1] = vecEnd
	if Input.is_action_just_released("click"):
		visible = false;
		var dir = vecStart - vecEnd
		if dir.x < 0 :
			dir.x = max(-1*max,dir.x)
		if dir.x >= 0 :
			dir.x = min(max,dir.x)
		if dir.y < 0 :
			dir.y = max(-1*max,dir.y)
		if dir.y >= 0 :
			dir.y = min(max,dir.y)
		player.direction = dir


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
