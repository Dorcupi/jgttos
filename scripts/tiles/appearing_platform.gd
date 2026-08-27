extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and not visible:
		visible = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player and visible:
		visible = false
