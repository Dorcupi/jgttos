extends Node2D
class_name GameController

@onready var scene_holder: Node = $Scene
@onready var ui_holder: Node = $UI
@onready var transition_holder: Node = $Transitions

var current_scene: Node = null
var current_scene_path: String = ""
var current_ui: Node = null
var current_ui_path: String = ""

var current_trans_node: Node
var current_trans_tween: Tween
var current_trans_path: String

const TRANSITION_FULL: Dictionary[String, float] = {
	"fade": 1.0,
	"chop": 0.0,
}

const TRANSITION_EMPTY: Dictionary[String, float] = {
	"fade": -1.0,
	"chop": 3.0
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_controller = self
	if Global.scene_pass != "":
		change_scene(Global.scene_pass)
	else:
		# Load splash screen
		print("FAKE LOADING SPLASH SCREEN")
		change_scene("res://scenes/levels/level_1.tscn")

func handle_start_transition(the_name, color = Color.WHITE) -> void:
	if the_name is String and color is Color:
			if transition_holder.has_node(the_name) and TRANSITION_EMPTY.has(the_name) and TRANSITION_FULL.has(the_name):
				current_trans_node = transition_holder.get_node(the_name)
				current_trans_path = the_name
				if current_trans_node is CanvasItem:
					if "material" in current_trans_node:
						if current_trans_node.material is ShaderMaterial:
							if current_trans_node is ColorRect:
								current_trans_node.color = color
							current_trans_tween = create_tween()
							current_trans_node.set_instance_shader_parameter("progress", TRANSITION_EMPTY[the_name])
							current_trans_node.visible = true
							current_trans_tween.tween_method(
								func(value) -> void:
									current_trans_node.set_instance_shader_parameter("progress", value),
								TRANSITION_EMPTY[current_trans_path],
								TRANSITION_FULL[current_trans_path],
								1.0
							)
							await current_trans_tween.finished
							current_trans_tween.kill()

func handle_end_transition() -> void:
	if current_trans_node and is_instance_valid(current_trans_node):
		if current_trans_node is CanvasItem:
			if "material" in current_trans_node:
				if current_trans_node.material is ShaderMaterial:
					current_trans_tween = create_tween()
					current_trans_node.set_instance_shader_parameter("progress", -1.0)
					current_trans_tween.tween_method(
						func(value) -> void:
							current_trans_node.set_instance_shader_parameter("progress", value),
						TRANSITION_FULL[current_trans_path],
						TRANSITION_EMPTY[current_trans_path],
						1.0
					)
					await current_trans_tween.finished
					current_trans_node.visible = false

func change_gui_scene(scene: String, transition: Array, delete: bool = true, keep_running: bool = false) -> void:
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
		await handle_end_transition()
	else:
		printerr("NO CURRENT UI SCENE RUNNING")
		return

func change_scene(scene: String, transition: Array = [], delete: bool = true, keep_running: bool = false) -> void:
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
	var new: Node = load(scene).instantiate()
	scene_holder.add_child(new)
	current_scene = new
	current_scene_path = scene
	await handle_end_transition()

func restart_scene(transition: Array) -> void:
	if current_scene != null and current_scene_path != "":
		if transition.size() > 1:
			await handle_start_transition(transition[0], transition[1])
		elif transition.size() == 1:
			await handle_start_transition(transition[0])
		current_scene.queue_free()
		while is_instance_valid(current_scene): await get_tree().physics_frame
		var new: Node = load(current_scene_path).instantiate()
		scene_holder.add_child(new)
		current_scene = new
		await handle_end_transition()
	else:
		printerr("NO CURRENT SCENE RUNNING")
		return
