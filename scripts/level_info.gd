extends CanvasLayer
class_name LevelInfo
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hint_panel_label: Label = $Control/HintPanel/Label
@onready var level_name_label: Label = $Control/LevelNamePanel/Label
@onready var timer: Timer = $Timer

var _in_animation: bool = false
var _is_setup: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	animation_player.play("appear")
	animation_player.pause()
	animation_player.seek(0, true)
	_is_setup = true

func setup(level_name: String, description: String) -> void:
	if not _is_setup:
		visible = false
		animation_player.play("appear")
		animation_player.pause()
		animation_player.seek(0, true)
		_is_setup = true
	level_name_label.text = level_name
	hint_panel_label.text = description
	visible = true
	_in_animation = true
	animation_player.play("appear")
	_is_setup = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if _in_animation:
		if anim_name == "appear":
			timer.start(1)
		if anim_name == "close":
			_in_animation = false


func _on_timer_timeout() -> void:
	if _in_animation:
		animation_player.play("close")
