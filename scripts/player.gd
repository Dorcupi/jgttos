extends CharacterBody2D
class_name Player

var movement_speed: float = 300.0
var deacceleration_speed: float = 300.0
var jump_velocity: float = -400.0
var extra_jumps: int = 0
var can_jump: bool = true

var used_extra_jumps: int = 0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_floor() and used_extra_jumps != extra_jumps:
		used_extra_jumps = extra_jumps
	if Input.is_action_just_pressed("jump") and is_on_floor() and can_jump:
		velocity.y = jump_velocity
	elif Input.is_action_just_pressed("jump") and not is_on_floor() and used_extra_jumps > 0 and can_jump:
		velocity.y = jump_velocity
		used_extra_jumps -= 1

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, deacceleration_speed)

	move_and_slide()
