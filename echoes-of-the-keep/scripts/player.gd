extends CharacterBody2D

@export var walk_speed: float = 180.0
@export var run_speed: float = 320.0
@export var acceleration: float = 2200.0
@export var friction: float = 2400.0

# ---------- Sprint stamina ----------
# 1.0 = täysi sprint, 0.0 = pelkkä walk
@export var sprint_drain_per_sec: float = 0.55     # isompi = nopeammin väsyy
@export var sprint_regen_per_sec: float = 0.43     # isompi = nopeammin palautuu
@export var sprint_regen_delay: float = 0.4       # viive ennen kuin palautuminen alkaa
@export var run_anim_threshold: float = 25.0       # jos current_speed > walk_speed + tämä -> käytä run animaatiota

# ---------- Combo ----------
# Klikkaus hyväksytään seuraavaan iskuun vain lopussa (tiukempi ikkuna)
@export var combo_chain_window: float = 0.18       # sekunteina (pienempi = tiukempi)
@export var combo_early_click_ignored: bool = true # jos true, liian aikainen klikkaus ei queuea

# Attack lunge
@export var lunge_speed: float = 260.0
@export var lunge_duration: float = 0.08

# Turn feel (pehmeä)
@export var turn_duration: float = 0.10
@export var turn_speed_multiplier: float = 0.80
@export var use_idle_turn: bool = false

@onready var sprite: AnimatedSprite2D = %sprite

enum State { MOVE, ATTACK }
var state: State = State.MOVE

# Facing: true=right, false=left
var facing_right: bool = true

# Input cache
var input_dir: Vector2 = Vector2.ZERO
var sprint_pressed: bool = false

# Sprint stamina runtime
var sprint_energy: float = 1.0
var sprint_regen_timer: float = 0.0

# Turn overlay
var is_turning: bool = false
var turn_timer: float = 0.0
var pending_after_turn: StringName = &"idle"

# run_to_idle overlay
var is_run_to_idle: bool = false
var last_move_was_run_anim: bool = false

# Combo runtime
var combo_step: int = 0
var in_attack_end: bool = false
var queued_next: bool = false

# Attack timing (combo window)
var attack_elapsed: float = 0.0
var attack_duration: float = 0.0

# Lunge runtime
var lunge_timer: float = 0.0
var lunge_dir: Vector2 = Vector2.ZERO


func _ready() -> void:
	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)
	_play_safe(&"idle")


func _physics_process(delta: float) -> void:
	current_camera()

	_read_movement_input()
	_update_sprint_energy(delta)

	_handle_attack_input(delta)

	match state:
		State.MOVE:
			_process_move(delta)
		State.ATTACK:
			_process_attack(delta)


# -------------------------
# INPUT
# -------------------------

func _read_movement_input() -> void:
	input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()

	sprint_pressed = Input.is_action_pressed("move_run")


# -------------------------
# SPRINT STAMINA
# -------------------------

func _update_sprint_energy(delta: float) -> void:
	var moving := (input_dir != Vector2.ZERO)

	if sprint_pressed and moving and sprint_energy > 0.0:
		# sprinting drains
		sprint_energy = maxf(0.0, sprint_energy - sprint_drain_per_sec * delta)
		sprint_regen_timer = sprint_regen_delay
	else:
		# regen after delay
		if sprint_regen_timer > 0.0:
			sprint_regen_timer = maxf(0.0, sprint_regen_timer - delta)
		else:
			sprint_energy = minf(1.0, sprint_energy + sprint_regen_per_sec * delta)


func _current_move_speed() -> float:
	# jos shift ei painettuna -> always walk
	if not sprint_pressed:
		return walk_speed

	# shift painettuna -> speed laskee energian mukaan kohti walkia
	return lerpf(walk_speed, run_speed, sprint_energy)


func _should_use_run_anim(current_speed: float) -> bool:
	return current_speed > (walk_speed + run_anim_threshold)


# -------------------------
# MOVE (turn + run_to_idle overlays)
# -------------------------

func _process_move(delta: float) -> void:
	# Turn overlay timer
	if is_turning:
		turn_timer -= delta
		if turn_timer <= 0.0:
			is_turning = false
			_play_safe(pending_after_turn)

	# run_to_idle voidaan keskeyttää heti kun tulee input
	if is_run_to_idle and input_dir != Vector2.ZERO:
		is_run_to_idle = false

	# Facing päivitys vain x:n mukaan
	if absf(input_dir.x) > 0.01:
		_set_facing_right(input_dir.x > 0.0)

	var base_speed := _current_move_speed()
	var speed := base_speed * (turn_speed_multiplier if is_turning else 1.0)
	var target_velocity := input_dir * speed

	# accelerate / friction
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()

	# ---- Animations päätellään INPUTISTA (seinä-case) ----
	if input_dir != Vector2.ZERO:
		is_run_to_idle = false

		var use_run_anim := _should_use_run_anim(base_speed)
		var base_anim: StringName = (&"run" if use_run_anim else &"walk")
		pending_after_turn = base_anim

		if not is_turning:
			_play_safe(base_anim)

		last_move_was_run_anim = use_run_anim
	else:
		# no input -> idle / run_to_idle
		if last_move_was_run_anim and not is_run_to_idle and _has_anim(&"run_to_idle"):
			is_run_to_idle = true
			last_move_was_run_anim = false
			is_turning = false
			_play_safe(&"run_to_idle")
		else:
			last_move_was_run_anim = false
			pending_after_turn = &"idle"
			if not is_turning and not is_run_to_idle:
				_play_safe(&"idle")


func _set_facing_right(new_right: bool) -> void:
	if new_right == facing_right:
		_apply_flip()
		return

	facing_right = new_right
	_apply_flip()

	if state != State.MOVE:
		return

	# idle_turn pois
	if input_dir == Vector2.ZERO:
		if use_idle_turn and _has_anim(&"idle_turn"):
			_start_turn(&"idle_turn", &"idle")
		return

	# Liikkeessä: overlay-turn + pieni hidaste
	var cur_speed := _current_move_speed()
	var use_run_turn := _should_use_run_anim(cur_speed)

	var turn_anim: StringName = (&"run_turn" if use_run_turn else &"walk_turn")
	var after_anim: StringName = (&"run" if use_run_turn else &"walk")
	_start_turn(turn_anim, after_anim)


func _start_turn(turn_anim: StringName, after_anim: StringName) -> void:
	if not _has_anim(turn_anim):
		return
	is_turning = true
	turn_timer = turn_duration
	pending_after_turn = after_anim
	_play_safe(turn_anim)


# -------------------------
# ATTACK / COMBO + LUNGE (tiukempi combo window)
# -------------------------

func _handle_attack_input(delta: float) -> void:
	if not Input.is_action_just_pressed("attack"):
		return

	if state == State.MOVE:
		_start_combo(1)
		return

	# ATTACK: hyväksy "next" vain combo-windowin aikana
	if state == State.ATTACK and combo_step < 3 and not in_attack_end:
		var time_left := maxf(0.0, attack_duration - attack_elapsed)
		if time_left <= combo_chain_window:
			queued_next = true
		elif not combo_early_click_ignored:
			# vaihtoehtoinen: jos haluat "bufferin", aseta false ja se queueaa heti
			queued_next = true


func _start_combo(step: int) -> void:
	state = State.ATTACK

	# katkaise overlayt
	is_turning = false
	is_run_to_idle = false

	combo_step = clampi(step, 1, 3)
	in_attack_end = false
	queued_next = false

	# Face mouse (x only)
	var mx := get_global_mouse_position().x
	facing_right = (mx >= global_position.x)
	_apply_flip()

	# lunge x
	lunge_dir = Vector2(1, 0) if facing_right else Vector2(-1, 0)
	lunge_timer = lunge_duration

	velocity = Vector2.ZERO
	_play_attack_anim(_attack_name(combo_step))


func _process_attack(delta: float) -> void:
	# attack movement
	if lunge_timer > 0.0:
		lunge_timer -= delta
		velocity = lunge_dir * lunge_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()

	# timing (combo window)
	attack_elapsed += delta


func _play_attack_anim(anim: StringName) -> void:
	_play_safe(anim)
	attack_elapsed = 0.0
	attack_duration = _estimate_anim_duration(anim)


func _estimate_anim_duration(anim: StringName) -> float:
	# kesto ~ framecount / fps
	if sprite.sprite_frames == null:
		return 0.0
	if not sprite.sprite_frames.has_animation(anim):
		return 0.0

	var frames := sprite.sprite_frames.get_frame_count(anim)
	var fps := sprite.sprite_frames.get_animation_speed(anim)
	if fps <= 0.0:
		return 0.0
	return float(frames) / fps


func _attack_name(step: int) -> StringName:
	return StringName("attack_%d" % step)


func _attack_end_name(step: int) -> StringName:
	return StringName("attack_%d_end" % step)


func _on_animation_finished(_anim_name: StringName = &"") -> void:
	# run_to_idle finished
	if state == State.MOVE and is_run_to_idle and sprite.animation == &"run_to_idle":
		is_run_to_idle = false
		if input_dir == Vector2.ZERO:
			_play_safe(&"idle")
		return

	# if a turn animation ends early, return
	if state == State.MOVE and is_turning and (sprite.animation == &"walk_turn" or sprite.animation == &"run_turn" or sprite.animation == &"idle_turn"):
		is_turning = false
		_play_safe(pending_after_turn)
		return

	if state == State.ATTACK:
		_on_attack_anim_finished()


func _on_attack_anim_finished() -> void:
	# attack_n finished
	if not in_attack_end:
		if queued_next and combo_step < 3:
			queued_next = false
			combo_step += 1
			in_attack_end = false

			lunge_dir = Vector2(1, 0) if facing_right else Vector2(-1, 0)
			lunge_timer = lunge_duration

			_play_attack_anim(_attack_name(combo_step))
			return

		# no next -> go end (ja tyhjennä queue varmuudeksi)
		in_attack_end = true
		queued_next = false
		_play_attack_anim(_attack_end_name(combo_step))
		return

	# attack_n_end finished -> combo ends
	_end_combo()


func _end_combo() -> void:
	state = State.MOVE
	combo_step = 0
	in_attack_end = false
	queued_next = false
	lunge_timer = 0.0
	_play_safe(&"idle")


# -------------------------
# Helpers
# -------------------------

func _apply_flip() -> void:
	sprite.flip_h = not facing_right


func _has_anim(anim: StringName) -> bool:
	return sprite.sprite_frames != null and sprite.sprite_frames.has_animation(anim)


func _play_safe(anim: StringName) -> void:
	if not _has_anim(anim):
		if anim != &"idle" and _has_anim(&"idle"):
			anim = &"idle"
		else:
			return

	if sprite.animation == anim and sprite.is_playing():
		_apply_flip()
		return

	sprite.play(anim)
	_apply_flip()


# -------------------------
# Team camera logic (UNCHANGED)
# -------------------------

func current_camera():
	if global.current_scene == "game_scene":
		$game_scene_camera.enabled = true
		$dungeon_camera.enabled = false
	elif global.current_scene == "dungeon_1":
		$game_scene_camera.enabled = false
		$dungeon_camera.enabled = true
