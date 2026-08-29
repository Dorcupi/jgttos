extends Node

const SCENES: Dictionary[String, String] = {
	"splash": "uid://cuchutf2br4d5",
	"main_menu": "uid://d1a2oareltnwj",
	"level_select": "uid://s3r2jik76p56",
	"level_info": "uid://hlv5k4ojd7h6"
}

const LEVELS: Dictionary[int, String] = {
	1: "uid://cv1cjqaakeuml",
	2: "uid://8tsikr5vdynw",
	3: "uid://c8x8seny7pxjr",
}

const UNPAUSABLE_SCENES: Array[String] = [
	SCENES.main_menu,
	SCENES.splash
]

const GAME_CONTROLLER_FILE = preload("uid://bsix1apl8x7k6")
const CAMERA_SHAKE = preload("uid://bnx6t5j5tms3d")
var game_controller: GameController
var scene_pass: String
var total_deaths: int = 0
var levels_unlocked: Array = [1]
var levels_beat: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not get_tree().current_scene is GameController:
		scene_pass = get_tree().current_scene.scene_file_path
		get_tree().call_deferred("change_scene_to_packed", GAME_CONTROLLER_FILE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
