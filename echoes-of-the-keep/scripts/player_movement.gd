extends CharacterBody2D

@export var walk_speed: float = 180.0
@export var run_speed: float = 320.0
@export var acceleration: float = 2200.0
@export var friction: float = 2400.0

# Combo buffer: kuinka kauan hyväksytään "seuraava isku" painallus
@export var combo_buffer_time: float = 0.25

var input_dir: Vector2 = Vector2.ZERO
var last_facing_right: bool = true

# --- ATTACK / COMBO ---
var is_attacking: bool = false
var combo_step: int = 0              # 0 = ei combossa, 1..3 = nykyinen isku
var buffered_next: bool = false      # painettiinko seuraavaa iskua ajoissa
var buffer_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = %sprite


func _ready() -> void:
	# Käynnistä idle heti
	_play_if_needed("idle")


func _physics_process(delta: float) -> void:
	# 1) Attack input (bufferointi)
	if Input.is_action_just_pressed("attack"):
		if not is_attacking:
			start_combo()
		else:
			buffered_next = true
			buffer_timer = combo_buffer_time

	# bufferin countdown
	if buffer_timer > 0.0:
		buffer_timer -= delta
		if buffer_timer <= 0.0:
			buffered_next = false

	# 2) Jos hyökätään, lukitaan liike (halutessa voit antaa pienen "slide")
	if is_attacking:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()
		return

	# 3) Normaali liike
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()

	# Suunta -> flip
	if input_dir.x > 0.0:
		last_facing_right = true
	elif input_dir.x < 0.0:
		last_facing_right = false
	sprite.flip_h = not last_facing_right

	var target_speed := run_speed if Input.is_action_pressed("run") else walk_speed
	var target_velocity := input_dir * target_speed

	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		_play_if_needed(_move_anim_name(target_speed))
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		_play_if_needed("idle")

	move_and_slide()


# ------------------------
# Combo / Attack logic
# ------------------------

func start_combo() -> void:
	# estetään "tuplakäynnistys"
	if is_attacking:
		return

	is_attacking = true
	buffered_next = false
	buffer_timer = 0.0
	combo_step = 1

	# Aja combo async
	_run_combo()


func _run_combo() -> void:
	# Tämä tehdään erillisenä jotta _physics_process ei jää odottamaan
	call_deferred("_combo_coroutine")


func _combo_coroutine() -> void:
	# step 1..3, jatkuu jos buffered_next on true oikeaan aikaan
	await _play_attack_step(combo_step)


func _play_attack_step(step: int) -> void:
	# Päivitä flip viimeisen suunnan mukaan
	sprite.flip_h = not last_facing_right

	# Soita itse isku
	var attack_name := "attack_%d" % step
	_play_force(attack_name)

	# Odota että isku loppuu
	await sprite.animation_finished

	# Jos pelaaja ehti pyytää seuraavaa ja step < 3, jatketaan
	if buffered_next and step < 3:
		buffered_next = false
		combo_step += 1
		await _play_attack_step(combo_step)
		return

	# Muuten soita end-animaatio (jos löytyy)
	var end_name := "attack_%d_end" % step
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(end_name):
		_play_force(end_name)
		await sprite.animation_finished

	# Paluu normaaliin
	is_attacking = false
	combo_step = 0
	_play_if_needed("idle")


# ------------------------
# Helpers
# ------------------------

func _move_anim_name(target_speed: float) -> String:
	# Jos haluat myöhemmin "run_to_idle" / "turn" -logiikan, lisätään sen päälle.
	if is_equal_approx(target_speed, run_speed):
		return "run"
	return "walk"


func _play_if_needed(anim_name: String) -> void:
	if sprite.animation != anim_name:
		sprite.play(anim_name)


func _play_force(anim_name: String) -> void:
	sprite.play(anim_name)
