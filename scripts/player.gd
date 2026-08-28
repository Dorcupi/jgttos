extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound_effect: AudioStreamPlayer = $Node/JumpSoundEffect
@onready var die_sound_effect: AudioStreamPlayer = $Node/DieSoundEffect
@onready var pass_screen_sound_effect: AudioStreamPlayer = $Node/PassScreenSoundEffect
@onready var win_sound_effect: AudioStreamPlayer = $Node/WinSoundEffect

signal touched_win_flag
signal reading_sign
signal stopped_reading_sign

var movement_speed: float = 300.0
var acceleration_speed: float = 15.0
var deacceleration_speed: float = 15.0
var coyote_time: float = 0.15
var _coyote_timer: float = 0.0
var jump_buffer_time: float = 0.15
var _jump_buffer_timer: float = 0.0
var jump_velocity: float = -400.0
var double_jump_velocity: float = -400.0
var variable_jump_cutoff: float = 0.5
var extra_jumps: int = 0
var _idle_time: float = 1.0
var _idle_timer: float = 0.0
var can_jump: bool = true
var can_move: bool = true
var active: bool = false

var _used_extra_jumps: int = 0
var _touched_win_flag: bool = false
var _reading_sign: bool = false

var _jumping: bool = false
var _falling: bool = false

var _last_direction: float = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		_coyote_timer -= delta
	else:
		_coyote_timer = coyote_time
	if active:
		if Input.is_action_just_pressed("jump"):
			_jump_buffer_timer = jump_buffer_time
		else:
			_jump_buffer_timer -= delta
		if _coyote_timer > 0 and _used_extra_jumps != extra_jumps:
			_used_extra_jumps = extra_jumps
		if _jump_buffer_timer > 0 and _coyote_timer > 0 and can_jump:
			velocity.y = jump_velocity
			_coyote_timer = 0
			_jump_buffer_timer = 0
			jump_sound_effect.pitch_scale = 1.0
			jump_sound_effect.play()
		elif Input.is_action_just_pressed("jump") and _coyote_timer <= 0 and _used_extra_jumps > 0 and can_jump:
			print("DOUBLE JUMP")
			velocity.y = double_jump_velocity
			_used_extra_jumps -= 1
			jump_sound_effect.pitch_scale = 1.0 + (0.2 * (extra_jumps - _used_extra_jumps))
			jump_sound_effect.play()
		elif _jump_buffer_timer > 0 and _coyote_timer <= 0 and _used_extra_jumps > 0:
			velocity.y = double_jump_velocity
			_jump_buffer_timer = 0
			jump_sound_effect.pitch_scale = 1.0 + (0.2 * (extra_jumps - _used_extra_jumps))
			jump_sound_effect.play()
		elif velocity.y < 0.0:
			if Input.is_action_just_released("jump"):
				velocity.y *= variable_jump_cutoff
		if velocity.y < 0.0:
			_jumping = true
			_falling = false
		elif velocity.y >= 0.0 and _coyote_timer < 0:
			_jumping = false
			_falling = true
		else:
			_jumping = false
			_falling = false

		var direction := Input.get_axis("left", "right")
		var velocity_weight: float = delta * (acceleration_speed if direction else deacceleration_speed)
		velocity.x = lerp(velocity.x, direction * movement_speed, velocity_weight)
		if direction != 0.0:
			_last_direction = direction
			_idle_timer = _idle_time
		else:
			_idle_timer -= delta
			if _idle_timer <= 0.0:
				_last_direction = 0.0
		animated_sprite_2d.flip_h = true if _last_direction < 0.0 else false
		if not _jumping and not _falling:
			if _last_direction != 0.0:
				if direction == 0.0:
					if not animated_sprite_2d.get_animation() == "idle_left": animated_sprite_2d.play("idle_left")
				else:
					if not animated_sprite_2d.get_animation() == "walk_left": animated_sprite_2d.play("walk_left")
			else:
				if not animated_sprite_2d.get_animation() == "idle_front": animated_sprite_2d.play("idle_front")
		elif _jumping:
			if _last_direction != 0.0:
				if not animated_sprite_2d.get_animation() == "jump_left": animated_sprite_2d.play("jump_left")
			else:
				if not animated_sprite_2d.get_animation() == "jump_front": animated_sprite_2d.play("jump_front")
		else:
			if _last_direction != 0.0:
				if not animated_sprite_2d.get_animation() == "fall_left": animated_sprite_2d.play("fall_left")
			else:
				if not animated_sprite_2d.get_animation() == "fall_front": animated_sprite_2d.play("fall_front")

	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if active:
		if area.get_parent() is WinFlag and not _touched_win_flag:
			touched_win_flag.emit()
			_touched_win_flag = true
			active = false
		elif area.get_parent() is TextSign and not _reading_sign:
			_reading_sign = true
			reading_sign.emit()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() is TextSign and _reading_sign:
			_reading_sign = false
			stopped_reading_sign.emit()
