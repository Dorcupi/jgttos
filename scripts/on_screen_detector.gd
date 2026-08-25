extends Area2D
class_name OnScreenDetector

var player_on_screen: bool = true

signal player_left_screen
signal player_entered_screen


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and not player_on_screen:
		player_on_screen = true
		player_entered_screen.emit()


func _on_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player and player_on_screen:
		player_on_screen = false
		player_left_screen.emit()
