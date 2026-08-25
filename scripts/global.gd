extends Node

const GAME_CONTROLLER_FILE = preload("res://scenes/game_controller.tscn")
var game_controller: GameController
var scene_pass: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not get_tree().current_scene is GameController:
		scene_pass = get_tree().current_scene.scene_file_path
		get_tree().call_deferred("change_scene_to_packed", GAME_CONTROLLER_FILE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
