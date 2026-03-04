extends CharacterBody2D

#
# enemy states
#
enum State {
	PATROL,
	CHASE,
	RETURN_HOME,
	ATTACK
}

var state: State = State.PATROL

#
# !! säädöt Inspectorissa !!
#
@export var patrol_speed: float = 35.0 # nopeus partioidessa
@export var chase_speed: float = 70.0 # nopeus jahdatessa
@export var patrol_distance: float = 60.0 # miten kauas lähtöpisteestä partioi
@export var patrol_vertical: bool = false # vertical vai horizontal patrol
@export var stop_distance: float = 18.0 # kuinka lähelle pelaajaa pysähtyy
@export var home_reach_distance: float = 6.0 # kuinka lähelle home pitää päästä että on home
@export var turn_pause_time: float = 0.25 # kauan patrolissa kääntyessä paikallaan
@export var attack_cooldown: float = 0.6  # kuinka kauan odotetaan iskun jälkeen ennen seuraavaa

@export var max_hp: int = 30
@export var attack_damage: int = 10
@export var attack_hit_time: float = 0.12 # sekuntia lyönnin alusta -> osumahetki

@onready var sprite: AnimatedSprite2D = $sprite
@onready var detect_area: Area2D = $DetectArea
@onready var lose_area: Area2D = $LoseArea
@onready var attack_area: Area2D = $AttackArea

var hp: int
var player: Node2D = null
var home_pos: Vector2
var patrol_dir: int = 1
var last_dir: Vector2 = Vector2.DOWN

var turn_pause_left: float = 0.0

# attack state
var attack_in_range: bool = false
var attacking: bool = false
var attack_cd_left: float = 0.0

# attack hit timing
var hit_timer_left: float = 0.0
var did_hit_this_swing: bool = false

var dead: bool = false

func _ready() -> void:
	hp = max_hp
	home_pos = global_position
	_play_anim("idle", last_dir)

# varmistus: attack-finish callback
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

	move_and_slide()


#
# PATROL
#
func _do_patrol(delta: float) -> void:
	# kääntyessä seiso hetki
	if turn_pause_left > 0.0:
		turn_pause_left -= delta
		velocity = Vector2.ZERO
		_play_anim("idle", last_dir)
		return

	var axis := Vector2.UP if patrol_vertical else Vector2.RIGHT
	var offset_along_axis := (global_position - home_pos).dot(axis)

	if abs(offset_along_axis) >= patrol_distance:
		patrol_dir *= -1
		turn_pause_left = turn_pause_time

	var dir := axis * patrol_dir
	velocity = dir * patrol_speed
	last_dir = _to_cardinal(dir)
	_play_anim("run", last_dir)


#
# CHASE
#
func _do_chase() -> void:
	if not is_instance_valid(player):
		player = null
		state = State.RETURN_HOME
		return

	# jos pelaaja on jo AttackAreassa -> hyökkää
	if attack_in_range:
		state = State.ATTACK
		velocity = Vector2.ZERO
		return

	var to_player := player.global_position - global_position
	var dist := to_player.length()

	# HUOM: jos stop_distance on isompi kuin AttackArea radius, enemy pysähtyy ennen rangea
	if dist <= stop_distance:
		velocity = Vector2.ZERO
		_play_anim("idle", last_dir)
		return

	var dir := to_player.normalized()
	velocity = dir * chase_speed
	last_dir = _to_cardinal(dir)
	_play_anim("run", last_dir)


#
# RETURN HOME
#
func _do_return_home() -> void:
	var to_home := home_pos - global_position
	var dist := to_home.length()

	if dist <= home_reach_distance:
		velocity = Vector2.ZERO
		state = State.PATROL
		_play_anim("idle", last_dir)
		return

	var dir := to_home.normalized()
	velocity = dir * patrol_speed
	last_dir = _to_cardinal(dir)
	_play_anim("run", last_dir)


#
# ATTACK
#
func _do_attack(delta: float) -> void:
	velocity = Vector2.ZERO

	# jos lyönti on kesken, odotetaan osumahetki + animaation loppu
	if attacking:
		if not did_hit_this_swing:
			hit_timer_left -= delta
			if hit_timer_left <= 0.0:
				_try_deal_damage()
				did_hit_this_swing = true
		return

	# lyönti ei ole käynnissä -> tarkista että pelaaja yhä rangessa
	if not attack_in_range or not is_instance_valid(player):
		state = State.CHASE
		return

	# cooldown ennen uuden lyönnin aloitusta
	if attack_cd_left > 0.0:
		_play_anim("idle", last_dir)
		return

	# aloita uusi lyönti
	attacking = true
	did_hit_this_swing = false
	hit_timer_left = attack_hit_time
	_play_anim("attack", last_dir)


func _try_deal_damage() -> void:
	# “varma” tapa: tarkistetaan overlap juuri osumahetkellä
	for b in attack_area.get_overlapping_bodies():
		if b != null and b is Node and b.is_in_group("player"):
			_deal_damage_to(b)

func _deal_damage_to(target: Node) -> void:
	# support: jos playerissä on public take_damage, käytä sitä
	if target.has_method("take_damage"):
		target.call("take_damage", attack_damage)
		return
	# fallback teidän nykyiseen (player.gd) _test_damageen
	if target.has_method("_test_damage"):
		target.call("_test_damage", attack_damage)


#
# SIGNALS: detect / lose / attack range
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
		# ei keskeytä lyöntiä jos kesken
		state = State.RETURN_HOME


func _on_attack_area_body_entered(body: Node2D) -> void:
	if dead:
		return
	if body.is_in_group("player"):
		player = body
		attack_in_range = true
		# jos ollaan jahdissa, voidaan vaihtaa heti attackiin
		if state == State.CHASE:
			state = State.ATTACK


func _on_attack_area_body_exited(body: Node2D) -> void:
	if dead:
		return
	if player != null and body == player:
		attack_in_range = false
		# ei state-muutosta


#
# kun hyökkäysanimaatio loppuu, päätetään mitä tehdään seuraavaksi
#
func _on_sprite_animation_finished() -> void:
	if dead:
		return
	if not sprite.animation.begins_with("attack_"):
		return

	attacking = false
	attack_cd_left = attack_cooldown

	if attack_in_range and is_instance_valid(player):
		state = State.ATTACK
	else:
		state = State.CHASE


#
# DAMAGE TAKING
#
func take_damage(dmg: int) -> void:
	if dead:
		return
	hp = maxi(0, hp - dmg)
	if hp <= 0:
		_die()

func _die() -> void:
	dead = true
	velocity = Vector2.ZERO
	state = State.PATROL
	
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
		await sprite.animation_finished
	
	queue_free()

#
# animaatiot
#
func _to_cardinal(v: Vector2) -> Vector2:
	if abs(v.x) > abs(v.y):
		return Vector2.RIGHT if v.x > 0.0 else Vector2.LEFT
	else:
		return Vector2.DOWN if v.y > 0.0 else Vector2.UP


func _play_anim(prefix: String, dir: Vector2) -> void:
	var anim := "%s_%s" % [prefix, _dir_to_suffix(dir)]
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)


func _dir_to_suffix(dir: Vector2) -> String:
	if dir == Vector2.UP:
		return "up"
	if dir == Vector2.DOWN:
		return "down"
	if dir == Vector2.LEFT:
		return "left"
	return "right"
