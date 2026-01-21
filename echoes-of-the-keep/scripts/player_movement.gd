extends CharacterBody2D

@export var mov_speed: float = 500.0

var character_direction: Vector2 = Vector2.ZERO
var last_dir: Vector2 = Vector2.DOWN

@onready var sprite: AnimatedSprite2D = %sprite


func _ready() -> void:
	sprite.play(_idle_anim_for_dir(last_dir))


func _physics_process(delta: float) -> void:
	character_direction.x = Input.get_axis("move_left", "move_right")
	character_direction.y = Input.get_axis("move_up", "move_down")
	character_direction = character_direction.normalized()

	# Päivitä viimeisin suunta vain jos liikutaan
	if character_direction != Vector2.ZERO:
		last_dir = _to_cardinal(character_direction)
		velocity = character_direction * mov_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, mov_speed)

	# Animaation valinta:
	if character_direction != Vector2.ZERO:
		# Teillä ei ehkä ole vielä run_* animaatioita -> fallback idleen
		var run_anim := _run_anim_for_dir(last_dir)
		if sprite.sprite_frames.has_animation(run_anim):
			_play_if_needed(run_anim)
		else:
			_play_if_needed(_idle_anim_for_dir(last_dir))
	else:
		_play_if_needed(_idle_anim_for_dir(last_dir))

	move_and_slide()


func _to_cardinal(v: Vector2) -> Vector2:
	# Valitse pääsuunta sen mukaan, kumpi akseli on vahvempi
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
