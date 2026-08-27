extends Node

const SCENES: Dictionary[String, String] = {
	"level_info": "res://scenes/level_info.tscn"
}

const LEVELS: Dictionary[int, String] = {
	1: "res://scenes/levels/level_1.tscn",
	2: "res://scenes/levels/level_2.tscn",
	3: "res://scenes/levels/level_3.tscn",
}

const GAME_CONTROLLER_FILE = preload("res://scenes/game_controller.tscn")
var game_controller: GameController
var scene_pass: String
var total_deaths: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not get_tree().current_scene is GameController:
		scene_pass = get_tree().current_scene.scene_file_path
		get_tree().call_deferred("change_scene_to_packed", GAME_CONTROLLER_FILE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
