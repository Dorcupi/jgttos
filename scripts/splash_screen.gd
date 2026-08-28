extends CanvasLayer

var timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.start(2)
	await timer.timeout
	Global.game_controller.change_scene(Global.SCENES.main_menu, ["chop", Color.BLACK])
