extends CanvasLayer

var _switching_scenes: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_controller.music_manager.current_level = Global.game_controller.music_manager.LEVELS.LEVEL_4

func _on_play_button_pressed() -> void:
	if not _switching_scenes:
		_switching_scenes = true
		Global.game_controller.change_scene(Global.SCENES.level_select, ["chop", Color.BLACK])


func _on_quit_button_pressed() -> void:
	if not _switching_scenes:
		_switching_scenes = true
		get_tree().quit()
