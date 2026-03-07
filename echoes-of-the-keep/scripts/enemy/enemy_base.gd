extends CharacterBody2D
#
# enemy states
#
enum State {
	PATROL,
	CHASE,
	RETURN_HOME,
	ATTACK,
	HIT,
	DEAD
}

var state: State = State.PATROL

#
# !! säädöt Inspectorissa !!
#
@export var patrol_speed: float = 35.0
@export var chase_speed: float = 70.0
@export var patrol_distance: float = 60.0
@export var patrol_vertical: bool = false
@export var stop_distance: float = 18.0
@export var home_reach_distance: float = 6.0
@export var turn_pause_time: float = 0.25
@export var attack_cooldown: float = 0.6

@export var max_hp: int = 30
@export var attack_damage: int = 10
@export var attack_hit_time: float = 0.12

# HIT / STUN
@export var hit_stun_time: float = 0.18

# kuoleeko pois vai jääkö corpse
@export var despawn_on_death: bool = false

@onready var sprite: AnimatedSprite2D = $sprite
@onready var detect_area: Area2D = $DetectArea
@onready var lose_area: Area2D = $LoseArea
@onready var attack_area: Area2D = $AttackArea
@onready var body_collider: CollisionShape2D = $CollisionShape2D

var hp: int
var player: Node2D = null
var home_pos: Vector2
var patrol_dir: int = 1

# left/right facing
var facing_right: bool = true

var turn_pause_left: float = 0.0

# attack
var attack_in_range: bool = false
var attacking: bool = false
var attack_cd_left: float = 0.0

# attack hit timing
var hit_timer_left: float = 0.0
var did_hit_this_swing: bool = false

# hit state
var hit_stun_left: float = 0.0

var dead: bool = false


func _ready() -> void:
	hp = max_hp
	home_pos = global_position
	_play_anim("idle")

	if not sprite.animation_finished.is_connected(_on_sprite_animation_finished):
		sprite.animation_finished.connect(_on_sprite_animation_finished)


func _physics_process(delta: float) -> void:
	if dead:
		return

	if attack_cd_left > 0.0:
		attack_cd_left -= delta

	match state:
		State.PATROL:
			_do_patrol(delta)
		State.CHASE:
			_do_chase()
		State.RETURN_HOME:
			_do_return_home()
		State.ATTACK:
			_do_attack(delta)
		State.HIT:
			_do_hit(delta)

	move_and_slide()


#
# PATROL
#
func _do_patrol(delta: float) -> void:
	if turn_pause_left > 0.0:
		turn_pause_left -= delta
		velocity = Vector2.ZERO
		_play_anim("idle")
		return

	var axis := Vector2.UP if patrol_vertical else Vector2.RIGHT
	var offset_along_axis := (global_position - home_pos).dot(axis)

	if abs(offset_along_axis) >= patrol_distance:
		patrol_dir *= -1
		turn_pause_left = turn_pause_time

	var dir := axis * patrol_dir
	velocity = dir * patrol_speed
	_set_facing_from_dir(dir)
	_play_anim("run")


#
# CHASE
#
func _do_chase() -> void:
	if not is_instance_valid(player):
		player = null
		state = State.RETURN_HOME
		return

	if attack_in_range:
		state = State.ATTACK
		velocity = Vector2.ZERO
		return

	var to_player := player.global_position - global_position
	var dist := to_player.length()

	if dist <= stop_distance:
		velocity = Vector2.ZERO
		_play_anim("idle")
		return

	var dir := to_player.normalized()
	velocity = dir * chase_speed
	_set_facing_from_dir(dir)
	_play_anim("run")


#
# RETURN HOME
#
func _do_return_home() -> void:
	var to_home := home_pos - global_position
	var dist := to_home.length()

	if dist <= home_reach_distance:
		velocity = Vector2.ZERO
		state = State.PATROL
		_play_anim("idle")
		return

	var dir := to_home.normalized()
	velocity = dir * patrol_speed
	_set_facing_from_dir(dir)
	_play_anim("run")


#
# ATTACK
#
func _do_attack(delta: float) -> void:
	velocity = Vector2.ZERO

	if attacking:
		if not did_hit_this_swing:
			hit_timer_left -= delta
			if hit_timer_left <= 0.0:
				_try_deal_damage()
				did_hit_this_swing = true
		return

	if not attack_in_range or not is_instance_valid(player):
		state = State.CHASE
		return

	if attack_cd_left > 0.0:
		_play_anim("idle")
		return

	# aloita lyönti
	attacking = true
	did_hit_this_swing = false
	hit_timer_left = attack_hit_time

	# käänny pelaajaan päin ennen lyöntiä
	_face_player_if_any()
	_play_anim("attack")


func _try_deal_damage() -> void:
	for b in attack_area.get_overlapping_bodies():
		if b != null and b is Node and b.is_in_group("player"):
			_deal_damage_to(b)

func _deal_damage_to(target: Node) -> void:
	if target.has_method("take_damage"):
		target.call("take_damage", attack_damage)
		return
	if target.has_method("_test_damage"):
		target.call("_test_damage", attack_damage)


#
# HIT
#
func _do_hit(delta: float) -> void:
	velocity = Vector2.ZERO
	hit_stun_left -= delta
	if hit_stun_left <= 0.0:
		# palataan järkevästi
		if is_instance_valid(player):
			state = State.CHASE
		else:
			state = State.RETURN_HOME
		_play_anim("idle")
		return

	# pidä hit-animaatio päällä stun aikana
	_play_anim("hit")


#
# SIGNALS
#
func _on_detect_area_body_entered(body: Node2D) -> void:
	if dead:
		return
	if body.is_in_group("player"):
		player = body
		state = State.CHASE


func _on_lose_area_body_exited(body: Node2D) -> void:
	if dead:
		return
	if player != null and body == player:
		player = null
		attack_in_range = false
		state = State.RETURN_HOME


func _on_attack_area_body_entered(body: Node2D) -> void:
	if dead:
		return
	if body.is_in_group("player"):
		player = body
		attack_in_range = true
		if state == State.CHASE:
			state = State.ATTACK


func _on_attack_area_body_exited(body: Node2D) -> void:
	if dead:
		return
	if player != null and body == player:
		attack_in_range = false


#
# kun animaatio loppuu
#
func _on_sprite_animation_finished() -> void:
	if dead:
		return

	# attack valmis
	if sprite.animation.begins_with("attack_"):
		attacking = false
		attack_cd_left = attack_cooldown
		if attack_in_range and is_instance_valid(player):
			state = State.ATTACK
		else:
			state = State.CHASE
		return

	# hit valmis -> älä jää viimeiseen frameen
	if sprite.animation.begins_with("hit_"):
		# jos stun jo ohi, palataan heti
		if hit_stun_left <= 0.0:
			if is_instance_valid(player):
				state = State.CHASE
			else:
				state = State.RETURN_HOME
			_play_anim("idle")
		return


#
# DAMAGE TAKING
#
func take_damage(dmg: int) -> void:
	if dead:
		return

	hp = maxi(0, hp - dmg)

	if hp <= 0:
		_die()
		return

	# keskeytä lyönti & mene hit-tilaan
	attacking = false
	did_hit_this_swing = true
	hit_timer_left = 0.0

	hit_stun_left = hit_stun_time
	_face_player_if_any()
	state = State.HIT
	_play_anim("hit")


func _die() -> void:
	dead = true
	state = State.DEAD
	velocity = Vector2.ZERO

	# pois käytöstä, ettei ruumis blokkaa tai triggeröi mitään
	if detect_area:
		detect_area.monitoring = false
	if lose_area:
		lose_area.monitoring = false
	if attack_area:
		attack_area.monitoring = false
	if body_collider:
		body_collider.disabled = true

	_face_player_if_any()

	# kuolemaanimaatio ensin
	_play_anim("death")
	await sprite.animation_finished

	# vaihda corpseen
	_play_anim("corpse")
	sprite.stop()

	# lopeta logiikka
	set_physics_process(false)
	set_process(false)


#
# helpers (left/right)
#
func _face_player_if_any() -> void:
	if is_instance_valid(player):
		facing_right = (player.global_position.x >= global_position.x)

func _set_facing_from_dir(dir: Vector2) -> void:
	if absf(dir.x) > 0.01:
		facing_right = dir.x >= 0.0

func _play_anim(prefix: String) -> void:
	var anim := "%s_%s" % [prefix, ("right" if facing_right else "left")]
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)
