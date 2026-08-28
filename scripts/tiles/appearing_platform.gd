extends Node2D
@onready var sound_effect: AudioStreamPlayer = $SoundEffect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and not visible:
		sound_effect.pitch_scale = randf_range(0.8, 1.2)
		sound_effect.play()
		visible = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player and visible:
		visible = false
