extends Node2D
class_name Level

enum DAYTIMES {
	DAWN,
	MORNING,
	EVENING,
	NIGHT
}

const DAYTIME_COLOURS: Dictionary[DAYTIMES, Color] = {
	DAYTIMES.DAWN: Color("ffbec2"),
	DAYTIMES.MORNING: Color("ffffff"),
	DAYTIMES.EVENING: Color("7996f9"),
	DAYTIMES.NIGHT: Color("19247e"),
}

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
@export var day_modulate: CanvasModulate: ## A CanvasModulate node that can be used to change the time of day
	set(value):
		if not is_instance_valid(day_modulate):
			day_modulate = value
			if is_node_ready():
				if time_of_day is DAYTIMES and not _day_colour_set_up:
					_setup_day_colour()
@export var world_barriers: Array[StaticBody2D]: ## An array containing two StaticBody2D nodes with world boundary CollisionShape2D nodes, the first one facing the right to be used from the left, and the second one vice versa.
	set(value):
		if value.size() == 2:
			if world_barriers and world_barriers.size() >= 2:
				if not is_instance_valid(world_barriers[0]) or not is_instance_valid(world_barriers[1]):
					world_barriers = value
					if is_node_ready():
						if is_instance_valid(level_bounding_box) and not _barriers_set_up:
							_setup_barriers()
			else:
				world_barriers = value
				if is_node_ready():
					if is_instance_valid(level_bounding_box) and not _barriers_set_up:
						_setup_barriers()
@export_group("Presentation")
@export var level_name: String = ""
@export var level_description: String = ""
@export var time_of_day: DAYTIMES = DAYTIMES.MORNING:
	set(value):
		if time_of_day != value:
			time_of_day = value
			_day_colour_set_up = false
			if is_node_ready():
				if is_instance_valid(day_modulate):
					_setup_day_colour()

@export_group("Level Features")
@export var jumping_allowed: bool = true
@export var double_jumps: int = 0
@export var screen_passing_allowed: bool = false
@export var player_movement_speed: float
@export var player_acceleration_speed: float
@export var player_deacceleration_speed: float
@export var player_coyote_time: float
@export var player_jump_buffer_time: float
@export var player_jump_velocity: float
@export var player_double_jump_velocity: float
@export var player_jump_cutoff: float
@export var death_to_water: bool = false

var _player_set_up: bool = false
var _main_camera_set_up: bool = false
var _player_camera_set_up: bool = false
var _on_screen_detector_set_up: bool = false
var _day_colour_set_up: bool = false
var _barriers_set_up: bool = false

var _player_camera_zoom_amount: float = 1.75

var _restart_requested: bool = false
var _won_level: bool = false
var _using_player_camera: bool = false
var _moving_camera_up: bool = true

var _fake_camera_player: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if world_barriers and level_bounding_box and not _barriers_set_up: _setup_barriers()
	if not _main_camera_set_up:
		if main_camera and level_bounding_box and player: _setup_main_camera()
	if player and not _player_set_up: _setup_player()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	if not _on_screen_detector_set_up:
		if screen_passing_allowed: _setup_screen_passing()
	if day_modulate and time_of_day is DAYTIMES and not _day_colour_set_up:
		_setup_day_colour()
	_setup_level_info()
	Global.game_controller.music_manager.current_level = Global.game_controller.music_manager.LEVELS.LEVEL_2

func _setup_level_info() -> void:
	if Global.game_controller:
		if Global.game_controller.current_ui and Global.game_controller.current_ui is LevelInfo:
			Global.game_controller.current_ui.setup(level_name, level_description)
		else:
			await Global.game_controller.change_gui_scene(Global.SCENES["level_info"])
			Global.game_controller.current_ui.setup(level_name, level_description)

func _setup_barriers() -> void:
	var viewport_size: Vector2 = level_bounding_box.shape.get_rect().size
	var viewport_position: Vector2 = level_bounding_box.to_global(level_bounding_box.shape.get_rect().position)
	var difference: float = (72 * 2) if screen_passing_allowed else 0
	world_barriers[0].global_position.x = viewport_position.x - difference
	world_barriers[1].global_position.x = viewport_position.x + viewport_size.x + difference
	_barriers_set_up = true

func _setup_player() -> void:
	player.touched_win_flag.connect(_win_level)
	player.reading_sign.connect(_switch_to_player_camera)
	player.stopped_reading_sign.connect(_switch_from_player_camera)
	if player_spawn_location:
		print("LLLA")
		player.set_deferred("global_position", player_spawn_location.global_position)
	player.can_jump = jumping_allowed
	player.extra_jumps = double_jumps
	if player_movement_speed: player.movement_speed = player_movement_speed
	if player_acceleration_speed: player.acceleration_speed = player_acceleration_speed
	if player_deacceleration_speed: player.deacceleration_speed = player_deacceleration_speed
	if player_coyote_time: player.coyote_time = player_coyote_time
	if player_jump_buffer_time: player.jump_buffer_time = player_jump_buffer_time
	if player_jump_velocity: player.jump_velocity = player_jump_velocity
	if player_double_jump_velocity: player.double_jump_velocity = player_double_jump_velocity
	if player_jump_cutoff: player.variable_jump_cutoff = player_jump_cutoff
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

func _switch_to_player_camera() -> void:
	if _player_camera_set_up and not _using_player_camera:
		_using_player_camera = true
		player_camera.priority = 6

func _switch_from_player_camera() -> void:
	if _player_camera_set_up and _using_player_camera:
		print("SWITCH BACK")
		_using_player_camera = false
		player_camera.priority = 0

func _setup_main_camera() -> void:
	var viewport_size: Vector2 = main_camera.get_viewport_rect().size
	var room_size: Vector2 = level_bounding_box.shape.get_rect().size
	var zoom_x: float = room_size.x / viewport_size.x
	var zoom_val: float = zoom_x # max(zoom_x, zoom_y) # min(zoom_x, zoom_y)
	var zoom: Vector2 = Vector2.ONE / zoom_val
	var window_size: Vector2 = get_window().size
	var required_height: float = window_size.y * 0.45
	var height_test_value: float = required_height / 2
	if not is_instance_valid(_fake_camera_player):
		_fake_camera_player = Node2D.new()
		_fake_camera_player.global_position.x = level_bounding_box.global_position.x # + (room_size.x / 2)
		_fake_camera_player.global_position.y = player.global_position.y - (64 * 2)
		add_child(_fake_camera_player)
	else: _fake_camera_player.global_position.x = level_bounding_box.global_position.x # + (room_size.x / 2)
	if player.global_position.y > _fake_camera_player.global_position.y - height_test_value and player.global_position.y < _fake_camera_player.global_position.y + height_test_value:
		_moving_camera_up = true
	else:
		_moving_camera_up = false
	_update_fake_player_position()
	main_camera.global_position = _fake_camera_player.global_position
	main_camera.set_follow_target(_fake_camera_player)
	main_camera.set_follow_offset(Vector2.ZERO)
	main_camera.set_follow_damping(true)
	main_camera.set_follow_damping_value(Vector2.ONE)
	# main_camera.set_limit_target(level_bounding_box.get_path())
	main_camera.zoom = zoom
	_main_camera_set_up = true

func _update_main_camera() -> void:
	var viewport_size: Vector2 = main_camera.get_viewport_rect().size
	var room_size: Vector2 = level_bounding_box.shape.get_rect().size
	var zoom_x: float = room_size.x / viewport_size.x
	var zoom_y: float = room_size.y / viewport_size.y
	var zoom_val: float = zoom_x # max(zoom_x, zoom_y) # min(zoom_x, zoom_y)
	var zoom: Vector2 = Vector2.ONE / zoom_val
	var window_size: Vector2 = get_window().size
	var required_height: float = window_size.y * 0.45
	var height_test_value: float = required_height / 2
	if not is_instance_valid(_fake_camera_player):
		_fake_camera_player = Node2D.new()
		_fake_camera_player.global_position.x = level_bounding_box.global_position.x # + (room_size.x / 2)
		_fake_camera_player.global_position.y = player.global_position.y - (64 * 2)
		add_child(_fake_camera_player)
	else: _fake_camera_player.global_position.x = level_bounding_box.global_position.x # + (room_size.x / 2)
	if player.global_position.y > _fake_camera_player.global_position.y - height_test_value and player.global_position.y < _fake_camera_player.global_position.y + height_test_value:
		_moving_camera_up = true
	else:
		_moving_camera_up = false
	_update_fake_player_position()
	# main_camera.global_position = _fake_camera_player.global_position
	main_camera.zoom = zoom
	if player_camera:
		player_camera.set_zoom(main_camera.zoom * _player_camera_zoom_amount)

func _on_viewport_size_changed() -> void:
	print("UPDATE CAMERA")
	_update_main_camera()

func _setup_day_colour() -> void:
	if DAYTIME_COLOURS.has(time_of_day):
		day_modulate.color = DAYTIME_COLOURS[time_of_day]
		_day_colour_set_up = true

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
			player.pass_screen_sound_effect.play()
			# player.global_position.x = wrapf(current_player_position.x, level_bounding_box.to_global(level_bounding_box.shape.get_rect().position).x - 32, level_bounding_box.to_global(level_bounding_box.shape.get_rect().position).x + 32)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		_request_restart()

func _request_restart(death: bool = false) -> void:
	if not _restart_requested and not _won_level:
		if Global.game_controller and Global.game_controller.current_scene == self:
			_restart_requested = true
			player.active = false
			if death:
				Global.total_deaths += 1
				player.die_sound_effect.play()
				if main_camera:
					main_camera.noise = Global.CAMERA_SHAKE
			Global.game_controller.restart_scene(["fade", Color.BLACK])

func _win_level() -> void:
	if not _won_level and not _restart_requested:
		if Global.game_controller and Global.game_controller.current_scene == self:
			_won_level = true
			player.win_sound_effect.play()
			var path: String = Global.game_controller.current_scene_path
			if not path.begins_with("uid://"):
				path = ResourceUID.id_to_text(ResourceLoader.get_resource_uid(path))
			var current_level: int = Global.LEVELS.find_key(path)
			if not Global.levels_beat.has(current_level): Global.levels_beat.append(current_level)
			if not Global.levels_unlocked.has(current_level + 1): Global.levels_unlocked.append(current_level + 1)
			if Global.LEVELS.has(current_level + 1):
				print("MOVING TO LEVEL %.0f" % (current_level + 1))
				Global.game_controller.change_scene(Global.LEVELS[current_level + 1], ["chop", Color.BLACK])
			else:
				print("BEAT ALL LEVELS, RESTARTING")
				Global.game_controller.change_scene(Global.LEVELS[1], ["chop", Color.BLACK])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player and reachable_tilemap_layers.size() > 0:
		for i in reachable_tilemap_layers:
			var cell = i.local_to_map(i.to_local(player.global_position))
			var data = i.get_cell_tile_data(cell)
			if data:
				if data.get_custom_data("is_water") and death_to_water:
					_request_restart(true)
	if player and _fake_camera_player and main_camera: _update_fake_player_position()

func _update_fake_player_position() -> void:
	if _moving_camera_up:
		_fake_camera_player.global_position.y = player.global_position.y - (64 * 2)
	else:
		_fake_camera_player.global_position.y = player.global_position.y
