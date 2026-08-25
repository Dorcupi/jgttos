extends Node2D
class_name GameController

@onready var scene_holder: Node = $Scene
@onready var ui_holder: Node = $UI

var current_scene: Node = null
var current_scene_path: String = ""
var current_ui: Node = null
var current_ui_path: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_controller = self
	if Global.scene_pass != "":
		change_scene(Global.scene_pass)
	else:
		# Load splash screen
		print("FAKE LOADING SPLASH SCREEN")
		change_scene("res://scenes/levels/level_1.tscn")

func change_gui_scene(scene: String, transition: String = "", delete: bool = true, keep_running: bool = false) -> void:
	if transition != "" or transition == "null":
		# Trigger start transition here
		pass
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
	if transition != "" or transition == "null":
		# Trigger finish transition here
		pass

func restart_gui_scene(transition: String = "") -> void:
	if current_ui != null and current_ui_path != "":
		if transition != "" or transition == "null":
			# Trigger start transition here
			pass
		current_ui.queue_free()
		while is_instance_valid(current_ui): await get_tree().physics_frame
		var new: Node = load(current_ui_path).instantiate()
		ui_holder.add_child(new)
		current_ui = new
		if transition != "" or transition == "null":
			# Trigger start transition here
			pass
	else:
		printerr("NO CURRENT UI SCENE RUNNING")
		return

func change_scene(scene: String, transition: String = "", delete: bool = true, keep_running: bool = false) -> void:
	if transition != "" or transition == "null":
		# Trigger start transition here
		pass
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
	if transition != "" or transition == "null":
		# Trigger finish transition here
		pass

func restart_scene(transition: String = "") -> void:
	if current_scene != null and current_scene_path != "":
		if transition != "" or transition == "null":
			# Trigger start transition here
			pass
		current_scene.queue_free()
		while is_instance_valid(current_scene): await get_tree().physics_frame
		var new: Node = load(current_scene_path).instantiate()
		scene_holder.add_child(new)
		current_scene = new
		if transition != "" or transition == "null":
			# Trigger start transition here
			pass
	else:
		printerr("NO CURRENT SCENE RUNNING")
		return
