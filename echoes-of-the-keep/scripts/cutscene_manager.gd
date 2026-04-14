extends Node

@onready var player = $"../player"
@onready var player_camera = $"../player/Camera2D"
@onready var cutscene_camera = $"../cutscene_camera"
@onready var sfx = get_node_or_null("cutscene_sfx")

var cutscene_active = false

func _input(event: InputEvent) -> void:
	if cutscene_active and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()

func pan_camera(target_position: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(
		cutscene_camera,
		"global_position",
		target_position,
		2.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

func play_pan_to(target_position: Vector2, hold_time: float = 1.5) -> void:
	cutscene_active = true
	player.can_move = false

	cutscene_camera.global_position = player_camera.global_position
	cutscene_camera.zoom = player_camera.zoom

	player_camera.enabled = false
	cutscene_camera.enabled = true

	await pan_camera(target_position)
	await get_tree().create_timer(hold_time).timeout

func return_to_player(return_time: float = 0.6) -> void:
	if player == null or player_camera == null or cutscene_camera == null:
		push_error("CutsceneManager: player / player_camera / cutscene_camera puuttuu.")
		return

	var tween = create_tween()
	tween.tween_property(
		cutscene_camera,
		"global_position",
		player.global_position,
		return_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

	player_camera.enabled = true
	player_camera.make_current()

	if player_camera.has_method("reset_smoothing"):
		player_camera.reset_smoothing()

	cutscene_camera.enabled = false
	player.can_move = true
	cutscene_active = false

func start_cutscene():
	if global.dungeon_activated:
		return
		
	cutscene_active = true
	player.can_move = false 
	cutscene_camera.global_position = player_camera.global_position
	cutscene_camera.zoom = player_camera.zoom 
	
	player_camera.enabled = false
	cutscene_camera.enabled = true
	
	await pan_camera(Vector2(560, 155))
	
	await get_tree().create_timer(2.0).timeout
	if sfx:
		sfx.play()
	EffectPlayer.play_impact(Vector2(560, 132))
	await get_tree().create_timer(2.0).timeout

	end_cutscene()

func end_cutscene():
	global.dungeon_activated = true
	cutscene_camera.enabled = false
	player_camera.enabled = true
	player.can_move = true
	cutscene_active = false
