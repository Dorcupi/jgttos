extends Node2D
class_name GameController

@onready var music_manager: MusicManager = $Music
@onready var scene_holder: Node = $Scene
@onready var ui_holder: Node = $UI
@onready var transition_holder: Node = $Transitions
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var continue_button: Button = $PauseMenu/PanelContainer2/VBoxContainer/ContinueButton
@onready var back_to_menu_button: Button = $PauseMenu/PanelContainer2/VBoxContainer/BackToMenuButton
@onready var quit_game_button: Button = $PauseMenu/PanelContainer2/VBoxContainer/QuitGameButton
@onready var level_select_button: Button = $PauseMenu/PanelContainer2/VBoxContainer/LevelSelectButton

var current_scene: Node = null
var current_scene_path: String = ""
var current_ui: Node = null
var current_ui_path: String = ""

var _current_trans_node: Node
var _current_trans_tween: Tween
var _current_trans_path: String

var _currently_paused: bool = false

var _scene_change_in_progress: bool = false

const TRANSITION_FULL: Dictionary[String, float] = {
	"fade": -1.0,
	"chop": 0.0,
	"diagsquares": -1.0
}

const TRANSITION_EMPTY: Dictionary[String, float] = {
	"fade": 1.0,
	"chop": 3.0,
	"diagsquares": 30.0
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_controller = self
	if Global.scene_pass != "":
		change_scene(Global.scene_pass)
	else:
		change_scene(Global.SCENES.splash)

func handle_start_transition(the_name, color = Color.WHITE) -> void:
	if the_name is String and color is Color:
			if transition_holder.has_node(the_name) and TRANSITION_EMPTY.has(the_name) and TRANSITION_FULL.has(the_name):
				_current_trans_node = transition_holder.get_node(the_name)
				_current_trans_path = the_name
				if _current_trans_node is CanvasItem:
					if "material" in _current_trans_node:
						if _current_trans_node.material is ShaderMaterial:
							if _current_trans_node is ColorRect:
								_current_trans_node.color = color
							_current_trans_tween = create_tween()
							_current_trans_node.set_instance_shader_parameter("progress", TRANSITION_EMPTY[the_name])
							_current_trans_node.visible = true
							_current_trans_tween.tween_method(
								func(value) -> void:
									_current_trans_node.set_instance_shader_parameter("progress", value),
								TRANSITION_EMPTY[_current_trans_path],
								TRANSITION_FULL[_current_trans_path],
								1.0
							)
							await _current_trans_tween.finished
							_current_trans_tween.kill()

func handle_end_transition() -> void:
	if _current_trans_node and is_instance_valid(_current_trans_node):
		if _current_trans_node is CanvasItem:
			if "material" in _current_trans_node:
				if _current_trans_node.material is ShaderMaterial:
					_current_trans_tween = create_tween()
					_current_trans_node.set_instance_shader_parameter("progress", -1.0)
					_current_trans_tween.tween_method(
						func(value) -> void:
							_current_trans_node.set_instance_shader_parameter("progress", value),
						TRANSITION_FULL[_current_trans_path],
						TRANSITION_EMPTY[_current_trans_path],
						1.0
					)
					await _current_trans_tween.finished
					_current_trans_node.visible = false

func change_gui_scene(scene: String, transition: Array = [], delete: bool = true, keep_running: bool = false) -> void:
	if transition.size() > 1:
		await handle_start_transition(transition[0], transition[1])
	elif transition.size() == 1:
		await handle_start_transition(transition[0])
	if current_ui != null:
		if delete:
			current_ui.queue_free()
			while is_instance_valid(current_ui): await get_tree().physics_frame
		elif keep_running:
			current_ui.visible = false
		else:
			ui_holder.remove_child(current_ui)
	var new: Node = load(scene).instantiate()
	ui_holder.add_child(new)
	current_ui = new
	current_ui_path = scene
	while not is_instance_valid(current_ui): await get_tree().physics_frame
	await handle_end_transition()

func restart_gui_scene(transition: Array = []) -> void:
	if current_ui != null and current_ui_path != "":
		if transition.size() > 1:
			await handle_start_transition(transition[0], transition[1])
		elif transition.size() == 1:
			await handle_start_transition(transition[0])
		current_ui.queue_free()
		while is_instance_valid(current_ui): await get_tree().physics_frame
		var new: Node = load(current_ui_path).instantiate()
		ui_holder.add_child(new)
		current_ui = new
		while not is_instance_valid(current_ui): await get_tree().physics_frame
		await handle_end_transition()
	else:
		printerr("NO CURRENT UI SCENE RUNNING")
		return

func change_scene(scene: String, transition: Array = [], delete: bool = true, keep_running: bool = false, ui_change: bool = false) -> void:
	if not _scene_change_in_progress:
		_scene_change_in_progress = true
		if transition.size() > 1:
			await handle_start_transition(transition[0], transition[1])
		elif transition.size() == 1:
			await handle_start_transition(transition[0])
		if current_scene != null:
			if delete:
				current_scene.queue_free()
				while is_instance_valid(current_scene): await get_tree().physics_frame
			elif keep_running:
				current_scene.visible = false
			else:
				scene_holder.remove_child(current_scene)
		if ui_change:
			if current_ui != null:
				if delete:
					current_ui.queue_free()
					while is_instance_valid(current_ui): await get_tree().physics_frame
				elif keep_running:
					current_ui.visible = false
				else:
					ui_holder.remove_child(current_ui)
				current_ui = null
				current_ui_path = ""
		var new: Node = load(scene).instantiate()
		scene_holder.add_child(new)
		current_scene = new
		current_scene_path = scene
		while not is_instance_valid(current_scene): await get_tree().physics_frame
		await handle_end_transition()
		_scene_change_in_progress = false

func restart_scene(transition: Array = []) -> void:
	if not _scene_change_in_progress:
		if current_scene != null and current_scene_path != "":
			_scene_change_in_progress = true
			if transition.size() > 1:
				await handle_start_transition(transition[0], transition[1])
			elif transition.size() == 1:
				await handle_start_transition(transition[0])
			current_scene.queue_free()
			while is_instance_valid(current_scene): await get_tree().physics_frame
			var new: Node = load(current_scene_path).instantiate()
			scene_holder.add_child(new)
			current_scene = new
			while not is_instance_valid(current_scene): await get_tree().physics_frame
			await handle_end_transition()
			_scene_change_in_progress = false
		else:
			printerr("NO CURRENT SCENE RUNNING")
			return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not _currently_paused:
			if not Global.UNPAUSABLE_SCENES.has(current_scene_path) and not Global.UNPAUSABLE_SCENES.has(current_ui_path):
				if not _current_trans_tween or not _current_trans_tween.is_valid() :
					_currently_paused = true
					pause_menu.visible = true
					continue_button.pressed.connect(unpause_game)
					if current_scene_path != Global.SCENES.main_menu:
						back_to_menu_button.visible = true
						back_to_menu_button.pressed.connect(unpause_to_menu)
					else:
						back_to_menu_button.visible = false
					if Global.LEVELS.values().has(current_scene_path):
						level_select_button.visible = true
						level_select_button.pressed.connect(unpause_to_level_select)
					else:
						level_select_button.visible = false
					quit_game_button.pressed.connect(unpause_quit)
					get_tree().paused = true

func unpause_quit() -> void:
	if unpause_game(): get_tree().quit()

func unpause_to_menu() -> void:
	if unpause_game(): change_scene(Global.SCENES.main_menu, ["chop", Color.BLACK], true, false, true)

func unpause_to_level_select() -> void:
	if unpause_game(): change_scene(Global.SCENES.level_select, ["chop", Color.BLACK], true, false, true)

func unpause_game() -> bool:
	var success: bool = false
	if _currently_paused:
		_currently_paused = false
		pause_menu.visible = false
		continue_button.pressed.disconnect(unpause_game)
		if back_to_menu_button.pressed.is_connected(unpause_to_menu): back_to_menu_button.pressed.disconnect(unpause_to_menu)
		if level_select_button.pressed.is_connected(unpause_to_level_select): level_select_button.pressed.disconnect(unpause_to_level_select)
		quit_game_button.pressed.disconnect(unpause_quit)
		get_tree().paused = false
		success = true
	return success
