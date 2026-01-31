extends CharacterBody2D

# !! säädöt Inspectorissa !!
@export var patrol_speed: float = 35.0
@export var chase_speed: float = 70.0

# patrol edestakaisin
@export var patrol_distance: float = 60.0
@export var patrol_vertical: bool = false  # false = vasen-oikea, true = ylös-alas

# sisäinen tila
var _start_pos: Vector2
var _dir: int = 1  # 1 tai -1
var _chasing: bool = false
var _target: Node2D = null
var _last_dir: Vector2 = Vector2.DOWN  # animaatioiden suunta

@onready var sprite: AnimatedSprite2D = $sprite
@onready var detect_area: Area2D = $DetectArea
@onready var lose_area: Area2D = $LoseArea


func _ready() -> void:
	_start_pos = global_position

	_play_if_needed(_idle_anim_for_dir(_last_dir))


func _physics_process(_delta: float) -> void:
	if _chasing and is_instance_valid(_target):
		_chase()
	else:
		_target = null
		_patrol()

	move_and_slide()
	_update_animation()


# liike

func _patrol() -> void:
	# liikutaan edestakaisin, käännytään kun ollaan liian kaukana startista
	var axis := Vector2.UP if patrol_vertical else Vector2.RIGHT
	var offset := (global_position - _start_pos).dot(axis)

	if abs(offset) >= patrol_distance:
		_dir *= -1

	var move_dir := axis * _dir
	velocity = move_dir * patrol_speed

	# päivitä viimeisin suunta
	_last_dir = _to_cardinal(move_dir)


func _chase() -> void:
	# juostaan kohti pelaajaa
	var to_target := (_target.global_position - global_position)
	if to_target.length() < 1.0:
		velocity = Vector2.ZERO
		return

	var move_dir := to_target.normalized()
	velocity = move_dir * chase_speed
	_last_dir = _to_cardinal(move_dir)


# detection (2 ympyrää)

func _on_detect_area_body_entered(body: Node2D) -> void:
	# aloita jahtaus kun pelaaja tulee pieneen ympyrään
	if body.is_in_group("player"):
		_chasing = true
		_target = body


func _on_lose_area_body_exited(body: Node2D) -> void:
	# lopeta jahtaus kun pelaaja poistuu isosta ympyrästä
	if body == _target:
		_chasing = false
		_target = null


# animaatiot

func _update_animation() -> void:
	# valitaan idle/run
	if velocity.length() > 1.0:
		_play_if_needed(_run_anim_for_dir(_last_dir))
	else:
		_play_if_needed(_idle_anim_for_dir(_last_dir))


func _to_cardinal(v: Vector2) -> Vector2:
	# muutetaan diagonaali lähimmäksi pääsuunnaksi
	if abs(v.x) > abs(v.y):
		return Vector2.RIGHT if v.x > 0.0 else Vector2.LEFT
	else:
		return Vector2.DOWN if v.y > 0.0 else Vector2.UP


func _idle_anim_for_dir(dir: Vector2) -> String:
	if dir == Vector2.UP:
		return "idle_up"
	if dir == Vector2.DOWN:
		return "idle_down"
	if dir == Vector2.LEFT:
		return "idle_left"
	return "idle_right"


func _run_anim_for_dir(dir: Vector2) -> String:
	if dir == Vector2.UP:
		return "run_up"
	if dir == Vector2.DOWN:
		return "run_down"
	if dir == Vector2.LEFT:
		return "run_left"
	return "run_right"


func _play_if_needed(anim: String) -> void:
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)
