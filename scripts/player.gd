extends CharacterBody2D
class_name Player

var movement_speed: float = 300.0
var acceleration_speed: float = 15.0
var deacceleration_speed: float = 15.0
var coyote_time: float = 0.15
var _coyote_timer: float = 0.0
var jump_buffer_time: float = 0.15
var _jump_buffer_timer: float = 0.0
var _testing_buffer: bool = false
var jump_velocity: float = -400.0
var double_jump_velocity: float = -400.0
var variable_jump_cutoff: float = 0.5
var extra_jumps: int = 0
var can_jump: bool = true
var can_move: bool = true
var active: bool = false

var _used_extra_jumps: int = 0

func _physics_process(delta: float) -> void:
	if active:
		if not is_on_floor():
			velocity += get_gravity() * delta
			_coyote_timer -= delta
		else:
			_coyote_timer = coyote_time
		if Input.is_action_just_pressed("jump"):
			_jump_buffer_timer = jump_buffer_time
		else:
			_jump_buffer_timer -= delta
			if _jump_buffer_timer <= 0 and _testing_buffer:
				if _coyote_timer <= 0:
					_used_extra_jumps -= 1
				_testing_buffer = false
		if _coyote_timer > 0 and _used_extra_jumps != extra_jumps:
			_used_extra_jumps = extra_jumps
		if _jump_buffer_timer > 0 and _coyote_timer > 0 and can_jump:
			velocity.y = jump_velocity
			_coyote_timer = 0
			_jump_buffer_timer = 0
		elif Input.is_action_just_pressed("jump") and _coyote_timer <= 0 and _used_extra_jumps > 0 and can_jump:
			velocity.y = double_jump_velocity
			_used_extra_jumps -= 1
		elif _jump_buffer_timer > 0 and _coyote_timer <= 0 and _used_extra_jumps > 0:
			velocity.y = double_jump_velocity
			_testing_buffer = true
			_jump_buffer_timer = 0
		elif velocity.y < 0.0:
			if Input.is_action_just_released("jump"):
				velocity.y *= variable_jump_cutoff

		var direction := Input.get_axis("left", "right")
		var velocity_weight: float = delta * (acceleration_speed if direction else deacceleration_speed)
		velocity.x = lerp(velocity.x, direction * movement_speed, velocity_weight)

	move_and_slide()
