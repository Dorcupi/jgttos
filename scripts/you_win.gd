extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var time_taken: Label = $CenterContainer/VBoxContainer/TimeTaken
@onready var total_deaths: Label = $CenterContainer/VBoxContainer/TotalDeaths
@onready var high_score: Label = $CenterContainer/VBoxContainer/HighScore

var _switching_scenes: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("loop")
	Global.game_controller.music_manager.current_level = Global.game_controller.music_manager.LEVELS.LEVEL_4
	time_taken.text = "TIME TAKEN: %.0fs" % Global.current_time_taken
	total_deaths.text = "TOTAL DEATHS: %.0f" % Global.current_total_deaths
	high_score.visible = Global.set_highscore


func _on_back_to_menu_button_pressed() -> void:
	if not _switching_scenes:
		_switching_scenes = true
		Global.completing_runthrough = false
		Global.game_controller.change_scene(Global.SCENES.main_menu, ["chop", Color.BLACK], true, false, true)


func _on_quit_button_pressed() -> void:
	if not _switching_scenes:
		_switching_scenes = true
		get_tree().quit()


func _on_restart_button_pressed() -> void:
	if not _switching_scenes:
		_switching_scenes = true
		Global.reset_runthrough_data()
		Global.game_controller.change_scene(Global.LEVELS[1], ["chop", Color.BLACK])
