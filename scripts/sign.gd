extends Node2D
class_name TextSign

@export var sign_text: Array[String]
@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if not label.visible:
			if sign_text.size() > 0:
				label.text = sign_text.pick_random()
				label.visible = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player:
		if label.visible:
			label.visible = false
