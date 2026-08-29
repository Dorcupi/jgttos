extends CanvasLayer

var timer: Timer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player.play()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.start(2)
	await timer.timeout
	Global.game_controller.music_manager.current_level = Global.game_controller.music_manager.LEVELS.LEVEL_1
	Global.game_controller.change_scene(Global.SCENES.main_menu, ["chop", Color.BLACK])
