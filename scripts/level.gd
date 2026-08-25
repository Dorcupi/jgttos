extends Node2D
class_name Level

@export_group("Setup")
@export var player: Player:
	set(value):
		if not is_instance_valid(player):
			player = value
			if is_node_ready():
				if not _player_set_up: _setup_player()
@export var player_spawn_location: Marker2D ## A Marker2D node in the position where you want the player to spawn. Since the player is 64px big, it is recommended to set the gizmo extends to 36px to prevent the player from spawning in the floor, and to give them a little hop.
@export var main_camera: PhantomCamera2D: ## A PhantomCamera2D node with its default settings, except for tween_on_load being set to false and follow_mode being set to Framed, with 0.75 Dead Zone Height.
	set(value):
		if not is_instance_valid(main_camera):
			main_camera = value
			if is_node_ready():
				if not _main_camera_set_up:
					if main_camera and level_bounding_box and player: _setup_main_camera()
@export var player_camera: PhantomCamera2D ## A PhantomCamera2D node with its default settings, except for tween_on_load being set to false and follow_mode being set to Glued (1).
@export var level_bounding_box: CollisionShape2D: ## A CollisionShape2D node (preferrably in an OnScreenDetector node) with the shape set as a rectangle that covers the entire level and one tile of the border, preferrably the same as the on screen detector shape.
	set(value):
		if not is_instance_valid(level_bounding_box):
			level_bounding_box = value
			if is_node_ready():
				if not _main_camera_set_up:
					if main_camera and level_bounding_box and player: _setup_main_camera()
@export var on_screen_detector: OnScreenDetector: ## An OnScreenDetector node that has a collision shape that covers the entire level and one tile of the border, preferrably the same as the level bounding box.
	set(value):
		if not is_instance_valid(on_screen_detector):
			on_screen_detector = value
			if is_node_ready():
				if not _on_screen_detector_set_up:
					if screen_passing_allowed: _setup_screen_passing()
@export var reachable_tilemap_layers: Array[TileMapLayer] ## An array filled with TileMapLayer nodes that the player can reach/touch/interact with. Used for detection on spikes, water, and other things.

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
@export var death_to_water: bool = false

var _player_set_up: bool = false
var _main_camera_set_up: bool = false
var _player_camera_set_up: bool = false
var _on_screen_detector_set_up: bool = false

var _player_camera_zoom_amount: float = 1.75

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player and not _player_set_up: _setup_player()
	if not _main_camera_set_up:
		if main_camera and level_bounding_box and player: _setup_main_camera()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	if not _on_screen_detector_set_up:
		if screen_passing_allowed: _setup_screen_passing()

func _setup_player() -> void:
	if player_spawn_location: player.global_position = player_spawn_location.global_position
	player.can_jump = jumping_allowed
	player.extra_jumps = double_jumps
	if player_movement_speed: player.movement_speed = player_movement_speed
	if player_deacceleration_speed: player.deacceleration_speed = player_deacceleration_speed
	if player_jump_velocity: player.jump_velocity = player_jump_velocity
	if player_camera and not _player_camera_set_up: _setup_player_camera()
	player.active = true
	_player_set_up = true

func _setup_player_camera() -> void:
	player_camera.set_follow_target(player)
	player_camera.set_follow_offset(Vector2.ZERO)
	player_camera.set_follow_damping(true)
	player_camera.set_follow_damping_value(Vector2(0.1, 0.1))
	# player_camera.set_limit_target(level_bounding_box.get_path())
	if main_camera:
		player_camera.set_zoom(main_camera.zoom * _player_camera_zoom_amount)
	_player_camera_set_up = true

func _setup_main_camera() -> void:
	var viewport_size: Vector2 = main_camera.get_viewport_rect().size
	var room_size: Vector2 = level_bounding_box.shape.get_rect().size
	var zoom_x: float = room_size.x / viewport_size.x
	var zoom_y: float = room_size.y / viewport_size.y
	var zoom_val: float = zoom_x # max(zoom_x, zoom_y) # min(zoom_x, zoom_y)
	var zoom: Vector2 = Vector2.ONE / zoom_val
	main_camera.set_follow_target(player)
	main_camera.set_follow_offset(Vector2.ZERO)
	main_camera.set_follow_damping(true)
	main_camera.set_limit_target(level_bounding_box.get_path())
	main_camera.zoom = zoom
	main_camera.global_position = level_bounding_box.global_position
	_main_camera_set_up = true

func _update_main_camera() -> void:
	var viewport_size: Vector2 = main_camera.get_viewport_rect().size
	var room_size: Vector2 = level_bounding_box.shape.get_rect().size
	var zoom_x: float = room_size.x / viewport_size.x
	var zoom_y: float = room_size.y / viewport_size.y
	var zoom_val: float = zoom_x # max(zoom_x, zoom_y) # min(zoom_x, zoom_y)
	var zoom: Vector2 = Vector2.ONE / zoom_val
	main_camera.zoom = zoom
	main_camera.global_position = level_bounding_box.global_position

func _on_viewport_size_changed() -> void:
	print("UPDATE CAMERA")
	_update_main_camera()

func _setup_screen_passing() -> void:
	on_screen_detector.player_left_screen.connect(_on_player_leave_screen)
	_on_screen_detector_set_up = true

func _on_player_leave_screen() -> void:
	if player:
		var current_player_position: Vector2 = player.global_position
		var viewport_size: Vector2 = level_bounding_box.shape.get_rect().size
		var viewport_position: Vector2 = level_bounding_box.to_global(level_bounding_box.shape.get_rect().position)
		var midpoint: float = viewport_size.x / 2
		if current_player_position.x <= viewport_position.x - 32 or current_player_position.x >= viewport_position.x + viewport_size.x + 32:
			var go_left: bool = false
			if current_player_position.x >= midpoint:
				go_left = true
			var new_player_position: Vector2 = current_player_position
			if go_left == true:
				new_player_position.x = viewport_position.x - 32
			else:
				new_player_position.x = viewport_position.x + viewport_size.x + 32
			player.global_position = new_player_position
			# player.global_position.x = wrapf(current_player_position.x, level_bounding_box.to_global(level_bounding_box.shape.get_rect().position).x - 32, level_bounding_box.to_global(level_bounding_box.shape.get_rect().position).x + 32)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		_request_restart()

func _request_restart() -> void:
	if Global.game_controller and Global.game_controller.current_scene == self:
		Global.game_controller.restart_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player and reachable_tilemap_layers.size() > 0:
		for i in reachable_tilemap_layers:
			var cell = i.local_to_map(i.to_local(player.global_position))
			var data = i.get_cell_tile_data(cell)
			if data:
				if data.get_custom_data("is_water") and death_to_water:
					_request_restart()
