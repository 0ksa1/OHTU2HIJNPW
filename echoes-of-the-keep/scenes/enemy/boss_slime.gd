extends CharacterBody2D

signal boss_died
signal health_changed(current_hp: int, max_hp: int)

enum State {
	INTRO,
	IDLE,
	CHASE,
	ATTACK,
	HIT,
	DEAD
}

@export var max_hp: int = 800
@export var move_speed: float = 55.0
@export var stop_distance: float = 30.0
@export var attack_damage: int = 15
@export var attack_hit_time: float = 0.18
@export var attack_cooldown: float = 1.35

# Knockback / stun
@export var knockback_force: float = 220.0
@export var knockback_friction: float = 900.0
@export var hit_stun_time: float = 0.44
@export var combo_stun_duration: float = 1.3

# Timed stun window:
# Jos boss saa 5 osumaa tämän ajan sisällä -> stun
@export var timed_stun_hit_count: int = 5
@export var timed_stun_window_seconds: float = 3.3

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_collider: CollisionShape2D = $CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var attack_area: Area2D = $AttackArea

@onready var sfx_hit: AudioStreamPlayer2D = $Slime_boss_hit
@onready var sfx_stunned: AudioStreamPlayer2D = $stunned

var current_hp: int
var dead: bool = false
var fight_active: bool = false
var state: State = State.INTRO

var player: Node2D = null
var facing_right: bool = true

var attack_in_range: bool = false
var attacking: bool = false
var attack_cd_left: float = 0.0
var hit_timer_left: float = 0.0
var did_hit_this_swing: bool = false

var hit_stun_left: float = 0.0

# Tallennetaan osumahetket sekunteina
var recent_hit_times: Array[float] = []
var timed_stun_active: bool = false

func _ready() -> void:
	current_hp = max_hp

	if attack_area != null:
		if not attack_area.body_entered.is_connected(_on_attack_area_body_entered):
			attack_area.body_entered.connect(_on_attack_area_body_entered)
		if not attack_area.body_exited.is_connected(_on_attack_area_body_exited):
			attack_area.body_exited.connect(_on_attack_area_body_exited)

	if sprite == null:
		push_error("BossSlime: AnimatedSprite2D-nodea ei löytynyt.")
		return

	if sprite.sprite_frames == null:
		push_error("BossSlime: SpriteFrames puuttuu.")
		return

	if not sprite.animation_finished.is_connected(_on_sprite_animation_finished):
		sprite.animation_finished.connect(_on_sprite_animation_finished)

	_play_idle_right()
	state = State.IDLE

func _physics_process(delta: float) -> void:
	if dead:
		return

	if attack_cd_left > 0.0:
		attack_cd_left -= delta

	_prune_old_hits()

	match state:
		State.INTRO:
			velocity = Vector2.ZERO
		State.IDLE:
			velocity = Vector2.ZERO
			if fight_active:
				state = State.CHASE
		State.CHASE:
			_do_chase()
		State.ATTACK:
			_do_attack(delta)
		State.HIT:
			_do_hit(delta)
		State.DEAD:
			velocity = Vector2.ZERO

	move_and_slide()

func start_fight() -> void:
	if dead:
		return

	fight_active = true
	player = get_tree().get_first_node_in_group("player") as Node2D
	state = State.CHASE

func play_intro_jump() -> void:
	state = State.INTRO

	if sprite == null or sprite.sprite_frames == null:
		push_error("BossSlime: sprite tai sprite_frames puuttuu jumpissa.")
		return

	if not sprite.sprite_frames.has_animation("jump_right"):
		push_error("BossSlime: jump_right animaatiota ei löytynyt.")
		return

	sprite.stop()
	sprite.speed_scale = 1.0
	sprite.animation = &"jump_right"
	sprite.frame = 0
	sprite.play()

	facing_right = true

func play_idle_after_intro() -> void:
	state = State.IDLE
	_play_idle_right()

func _do_chase() -> void:
	if not fight_active:
		state = State.IDLE
		velocity = Vector2.ZERO
		_play_idle_anim()
		return

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
		if not is_instance_valid(player):
			velocity = Vector2.ZERO
			_play_idle_anim()
			return

	if attack_in_range:
		state = State.ATTACK
		velocity = Vector2.ZERO
		_play_idle_anim()
		return

	var to_player := player.global_position - global_position
	var dist := to_player.length()

	if dist <= stop_distance:
		velocity = Vector2.ZERO
		state = State.ATTACK
		_play_idle_anim()
		return

	var dir := to_player.normalized()
	velocity = dir * move_speed
	_set_facing_from_dir(dir)
	_play_anim_prefix("run")

func _do_attack(delta: float) -> void:
	velocity = Vector2.ZERO

	if not fight_active:
		state = State.IDLE
		return

	if attacking:
		if not did_hit_this_swing:
			hit_timer_left -= delta
			if hit_timer_left <= 0.0:
				_try_deal_damage()
				did_hit_this_swing = true
		return

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
		state = State.CHASE
		return

	if not attack_in_range:
		var dist := global_position.distance_to(player.global_position)
		if dist > stop_distance:
			state = State.CHASE
			return

	if attack_cd_left > 0.0:
		_play_idle_anim()
		return

	attacking = true
	did_hit_this_swing = false
	hit_timer_left = attack_hit_time

	_face_player_if_any()
	_play_anim_prefix("attack")

func _try_deal_damage() -> void:
	for b in attack_area.get_overlapping_bodies():
		if b != null and b is Node and b.is_in_group("player"):
			if b.has_method("take_damage"):
				b.call("take_damage", attack_damage)
				return

			if b.has_method("_test_damage"):
				b.call("_test_damage", attack_damage)
				return

func receive_player_hit(dmg: int, hit_info: Dictionary = {}) -> void:
	take_damage(dmg)

	if dead:
		return

	_register_timed_stun_hit()

func take_damage(dmg: int) -> void:
	if dead:
		return

	_play_hit_sfx()

	current_hp = max(0, current_hp - dmg)
	health_changed.emit(current_hp, max_hp)

	if current_hp <= 0:
		die()
		return

	play_hit()

func play_hit() -> void:
	if dead:
		return

	# Jos boss on jo timed stunissa, älä ylikirjoita sitä kevyellä hitillä
	if timed_stun_active:
		return

	attacking = false
	did_hit_this_swing = true
	hit_timer_left = 0.0
	attack_cd_left = max(attack_cd_left, 0.45)

	var kb_dir := Vector2.ZERO

	if is_instance_valid(player):
		var x_dir: float = signf(global_position.x - player.global_position.x)
		if x_dir == 0.0:
			x_dir = 1.0 if facing_right else -1.0
		kb_dir = Vector2(x_dir, 0.0)
		facing_right = kb_dir.x > 0.0
	else:
		kb_dir = Vector2.RIGHT if facing_right else Vector2.LEFT

	velocity = kb_dir * knockback_force
	hit_stun_left = hit_stun_time
	state = State.HIT

	if sprite != null and sprite.sprite_frames != null and _has_anim(_anim_name("hit")):
		sprite.stop()
		sprite.speed_scale = 1.0
		sprite.animation = _anim_name("hit")
		sprite.frame = 0
		sprite.play()

func _do_hit(delta: float) -> void:
	hit_stun_left -= delta
	velocity = velocity.move_toward(Vector2.ZERO, knockback_friction * delta)

	if hit_stun_left <= 0.0:
		velocity = Vector2.ZERO

		if dead:
			return

		timed_stun_active = false

		if fight_active:
			state = State.CHASE
			_play_idle_anim()
		else:
			state = State.IDLE
			_play_idle_anim()
		return

	if _has_anim(_anim_name("hit")):
		_play_anim_prefix("hit")

func die() -> void:
	if dead:
		return

	dead = true
	state = State.DEAD
	fight_active = false
	velocity = Vector2.ZERO
	timed_stun_active = false

	if body_collider != null:
		body_collider.disabled = true

	if hurtbox != null:
		hurtbox.monitoring = false
		hurtbox.monitorable = false

	if attack_area != null:
		attack_area.monitoring = false
		attack_area.monitorable = false

	if _has_anim(_anim_name("death")):
		sprite.stop()
		sprite.speed_scale = 1.0
		sprite.animation = _anim_name("death")
		sprite.frame = 0
		sprite.play()

		await sprite.animation_finished

	boss_died.emit()
	queue_free()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if dead:
		return

	if body.is_in_group("player"):
		player = body
		attack_in_range = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	if dead:
		return

	if player != null and body == player:
		attack_in_range = false

func _on_sprite_animation_finished() -> void:
	if dead:
		return

	if sprite.animation.begins_with("attack_"):
		attacking = false
		attack_cd_left = attack_cooldown

		if fight_active:
			state = State.CHASE
		else:
			state = State.IDLE

func _play_idle_right() -> void:
	if sprite == null or sprite.sprite_frames == null:
		push_error("BossSlime: sprite tai sprite_frames puuttuu idlessä.")
		return

	if not _has_anim("idle_right"):
		push_error("BossSlime: idle_right animaatiota ei löytynyt.")
		return

	sprite.stop()
	sprite.speed_scale = 1.0
	sprite.animation = &"idle_right"
	sprite.frame = 0
	sprite.play()

	facing_right = true

func _play_idle_anim() -> void:
	_play_anim_prefix("idle")

func _play_anim_prefix(prefix: String) -> void:
	var anim := _anim_name(prefix)
	if not _has_anim(anim):
		return

	if sprite.animation == anim and sprite.is_playing():
		return

	sprite.stop()
	sprite.speed_scale = 1.0
	sprite.animation = anim
	sprite.frame = 0
	sprite.play()

func _anim_name(prefix: String) -> StringName:
	return StringName("%s_%s" % [prefix, ("right" if facing_right else "left")])

func _has_anim(anim: StringName) -> bool:
	return sprite != null and sprite.sprite_frames != null and sprite.sprite_frames.has_animation(anim)

func _face_player_if_any() -> void:
	if is_instance_valid(player):
		facing_right = (player.global_position.x >= global_position.x)

func _set_facing_from_dir(dir: Vector2) -> void:
	if absf(dir.x) > 0.01:
		facing_right = dir.x >= 0.0

func _play_hit_sfx() -> void:
	if sfx_hit != null and sfx_hit.stream != null:
		sfx_hit.pitch_scale = randf_range(0.97, 1.03)
		sfx_hit.play()

func _play_stunned_sfx() -> void:
	if sfx_stunned != null and sfx_stunned.stream != null:
		sfx_stunned.pitch_scale = randf_range(0.98, 1.02)
		sfx_stunned.play()

func _register_timed_stun_hit() -> void:
	if dead:
		return

	var now: float = Time.get_ticks_msec() / 1000.0
	recent_hit_times.append(now)
	_prune_old_hits()

	if recent_hit_times.size() >= timed_stun_hit_count:
		_trigger_timed_stun()

func _prune_old_hits() -> void:
	var now: float = Time.get_ticks_msec() / 1000.0
	var pruned: Array[float] = []

	for hit_time in recent_hit_times:
		if now - hit_time <= timed_stun_window_seconds:
			pruned.append(hit_time)

	recent_hit_times = pruned

func _trigger_timed_stun() -> void:
	if dead:
		return

	timed_stun_active = true

	attacking = false
	did_hit_this_swing = true
	hit_timer_left = 0.0
	attack_cd_left = max(attack_cd_left, combo_stun_duration)

	velocity = Vector2.ZERO
	hit_stun_left = max(hit_stun_left, combo_stun_duration)
	state = State.HIT

	_play_stunned_sfx()

	# Tyhjennä osumaikkuna, ettei stun chainaa heti uudestaan
	recent_hit_times.clear()

	if _has_anim(_anim_name("hit")):
		sprite.stop()
		sprite.speed_scale = 1.0
		sprite.animation = _anim_name("hit")
		sprite.frame = 0
		sprite.play()
