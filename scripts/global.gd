extends Node

const SCENES: Dictionary[String, String] = {
	"splash": "uid://cuchutf2br4d5",
	"main_menu": "uid://d1a2oareltnwj",
	"level_select": "uid://s3r2jik76p56",
	"level_info": "uid://hlv5k4ojd7h6",
	"you_win": "uid://bb3glfv6l8j83"
}

const LEVELS: Dictionary[int, String] = {
	1: "uid://cv1cjqaakeuml",
	2: "uid://8tsikr5vdynw",
	3: "uid://c8x8seny7pxjr",
	4: "uid://0ybof5jwjywc",
	5: "uid://d0e4n5itwgc5i",
	6: "uid://53i72iuty123",
	7: "uid://bbu2kjf3vkvbb",
	8: "uid://6m7s35ghcbcq",
	9: "uid://npwrraoyhbyw",
	10: "uid://bubuki0fehnic",
	11: "uid://7lvkcfoxli3r",
	12: "uid://bib06i2pk8bgp"
}

const UNPAUSABLE_SCENES: Array[String] = [
	SCENES.main_menu,
	SCENES.splash,
	SCENES.you_win
]

const GAME_CONTROLLER_FILE = preload("uid://bsix1apl8x7k6")
const CAMERA_SHAKE = preload("uid://bnx6t5j5tms3d")
var game_controller: GameController
var scene_pass: String
var completing_runthrough: bool = true
var next_level: int = 1
var current_total_deaths: int = 0
var current_time_taken: float = 0.0
var least_total_deaths: int = 0
var least_time_taken: float = 0.0
var set_highscore: bool = false
var first_runthrough: bool = true
var levels_unlocked: Array = [1]
var levels_beat: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not get_tree().current_scene is GameController:
		scene_pass = get_tree().current_scene.scene_file_path
		get_tree().call_deferred("change_scene_to_packed", GAME_CONTROLLER_FILE)

func update() -> void:
	if first_runthrough:
		set_highscore = true
		least_time_taken = current_time_taken
		least_total_deaths = current_total_deaths
	elif current_time_taken < least_time_taken:
		set_highscore = true
		least_time_taken = current_time_taken
		least_total_deaths = current_total_deaths
	elif current_time_taken == least_time_taken and current_total_deaths < least_total_deaths:
		set_highscore = true
		least_time_taken = current_time_taken
		least_total_deaths = current_total_deaths
	else: set_highscore = false

func reset_runthrough_data() -> void:
	current_total_deaths = 0
	current_time_taken = 0.0
	next_level = 1
	set_highscore = false
	first_runthrough = false
