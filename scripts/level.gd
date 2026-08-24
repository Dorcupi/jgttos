extends Node2D
class_name Level

@export_group("Setup")
@export var player: Player
@export var main_camera: PhantomCamera2D ## A PhantomCamera2D node with its default settings, except for tween_on_load being set to false.
@export var player_camera: PhantomCamera2D ## A PhantomCamera2D node with its default settings, except for tween_on_load being set to false and follow_mode being set to Glued (1).
@export var level_bounding_box: CollisionShape2D ## A CollisionShape2D node with the shape set as a rectangle that covers the entire level and one tile of the border.

@export_group("Presentation")
@export var level_name: String = ""
@export var level_description: String = ""

@export_group("Level Features")
@export var jumping_allowed: bool = true
@export var double_jumps: int = 0
@export var screen_passing_allowed: bool = false
@export var player_movement_speed: float
@export var player_deacceleration_speed: float
@export var player_jump_velocity: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player:
		player.can_jump = jumping_allowed
		player.extra_jumps = double_jumps
		if player_movement_speed: player.movement_speed = player_movement_speed
		if player_deacceleration_speed: player.deacceleration_speed = player_deacceleration_speed
		if player_jump_velocity: player.jump_velocity = player_jump_velocity
	if main_camera and level_bounding_box: zoom_camera_to_fit_room()
	if player_camera and player:
		print("hi")
		setup_player_camera()

func setup_player_camera() -> void:
	player_camera.set_follow_target(player)
	player_camera.set_follow_offset(Vector2.ZERO)
	player_camera.set_follow_damping(true)
	player_camera.set_follow_damping_value(Vector2(0.1, 0.1))
	if main_camera:
		player_camera.set_zoom(main_camera.zoom * 1.5)

func zoom_camera_to_fit_room() -> void:
	var viewport_size: Vector2 = main_camera.get_viewport_rect().size
	var room_size: Vector2 = level_bounding_box.shape.get_rect().size
	var zoom_x: float = room_size.x / viewport_size.x
	var zoom_y: float = room_size.y / viewport_size.y
	var zoom_val: float = max(zoom_x, zoom_y)
	var zoom: Vector2 = Vector2.ONE / zoom_val
	main_camera.zoom = zoom
	main_camera.global_position = level_bounding_box.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
