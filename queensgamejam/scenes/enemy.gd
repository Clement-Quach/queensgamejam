extends Node2D  # or KinematicBody2D if using physics

@export var speed: float = 150.0
@export var follow_duration: float = 2.0  # seconds to follow the player
var player_scene = preload("res://scenes/player.tscn")
enum State { FOLLOW, ESCAPE }
var state: State = State.FOLLOW
var follow_timer: float = follow_duration
var escape_direction: Vector2 = Vector2.ZERO




var player: Node2D = null

func _ready() -> void:
	# Get a reference to the player node; update the path accordingly.
	player = get_node("/root/main/player")  # Adjust the path as needed
	follow_timer = follow_duration

func _process(delta: float) -> void:
	match state:
		State.FOLLOW:
			follow_timer -= delta
			if follow_timer > 0:
				# Calculate the direction toward the player and move
				var direction = (player.global_position - global_position).normalized()
				global_position += direction * speed * delta
			else:
				# Capture the last direction and switch state
				escape_direction = (player.global_position - global_position).normalized()
				state = State.ESCAPE
		State.ESCAPE:
			# Continue moving in the captured direction
			global_position += escape_direction * speed * delta
			# Check if enemy is off screen; if so, delete it
			if is_off_screen():
				queue_free()

# Helper function to check if the enemy is off screen
func is_off_screen() -> bool:
	var viewport_rect = get_viewport().get_visible_rect()
	return not viewport_rect.has_point(global_position)
