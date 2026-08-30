extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var level_buttons: GridContainer = $CenterContainer/VBoxContainer/LevelButtons

var _opening_level: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("loop")
	_setup_buttons()
	Global.game_controller.music_manager.current_level = Global.game_controller.music_manager.LEVELS.LEVEL_3

func _setup_buttons() -> void:
	for i in level_buttons.get_children():
		if i is Button:
			i.disabled = not Global.levels_unlocked.has(int(i.name))
			if Global.levels_unlocked.has(int(i.name)):
				i.pressed.connect(func():
					if Global.LEVELS.has(int(i.name)):
						if not _opening_level:
							_opening_level = true
							Global.game_controller.change_scene(Global.LEVELS[int(i.name)], ["chop", Color.BLACK]))
