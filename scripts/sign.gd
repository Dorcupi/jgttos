extends Node2D
class_name TextSign

enum SIGN_STYLES {
	PLAIN,
	PLAIN_LEFT,
	PLAIN_RIGHT,
	LEFT,
	RIGHT
}

@export var sign_text: Array[String]
@export var sign_style: SIGN_STYLES
@onready var label: Label = $Label

@onready var plain_sign: Sprite2D = $PlainSign
@onready var left_sign: Sprite2D = $LeftSign
@onready var right_sign: Sprite2D = $RightSign
@onready var plain_left_sign: Sprite2D = $PlainLeftSign
@onready var plain_right_sign: Sprite2D = $PlainRightSign

@onready var signs: Array[Node] = [plain_sign, left_sign, right_sign, plain_left_sign, plain_right_sign]

@onready var visible_signs: Dictionary[SIGN_STYLES, Array] = {
	SIGN_STYLES.PLAIN: [plain_sign],
	SIGN_STYLES.PLAIN_LEFT: [plain_left_sign],
	SIGN_STYLES.PLAIN_RIGHT: [plain_right_sign],
	SIGN_STYLES.LEFT: [left_sign],
	SIGN_STYLES.RIGHT: [right_sign]
}


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in signs:
		i.visible = visible_signs[sign_style].has(i)


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
