extends AudioStreamPlayer
class_name MusicManager

enum LEVELS {
	OFF,
	LEVEL_1,
	LEVEL_2,
	LEVEL_3,
	LEVEL_4
}

const LEVEL_STRINGS: Dictionary = {
	LEVELS.OFF: &"Clip 0",
	LEVELS.LEVEL_1: &"Level 1",
	LEVELS.LEVEL_2: &"Level 2",
	LEVELS.LEVEL_3: &"Level 3",
	LEVELS.LEVEL_4: &"Level 4",
}

@onready var _music: AudioStreamPlaybackInteractive = self.get_stream_playback()

@export var current_level: LEVELS = LEVELS.OFF:
	set(value):
		if value != current_level:
			current_level = value
			_change_level()

func _ready() -> void:
	_change_level()

func _change_level() -> void:
	if not playing:
		if current_level == LEVELS.OFF: pass
		else:
			_music.switch_to_clip_by_name(LEVEL_STRINGS[current_level])
			playing = true
	else: _music.switch_to_clip_by_name(LEVEL_STRINGS[current_level])
