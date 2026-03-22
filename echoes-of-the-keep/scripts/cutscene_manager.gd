extends Node

@onready var player = $"../player"
@onready var player_camera = $"../player/Camera2D"
@onready var cutscene_camera = $"../cutscene_camera"
var cutscene_active = false

func pan_camera(target_position: Vector2):
	var tween = create_tween()
	
	tween.tween_property(
		cutscene_camera,
		"position",
		target_position,
		2.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished

func start_cutscene():
	cutscene_active = true
	
	cutscene_camera.global_position = player_camera.global_position
	cutscene_camera.zoom = player_camera.zoom 
	
	player_camera.enabled = false
	cutscene_camera.enabled = true
	
	await pan_camera(Vector2(560, 155))
	
	await get_tree().create_timer(2.0).timeout
	end_cutscene()

func end_cutscene():
	cutscene_camera.enabled = false
	player_camera.enabled = true
	cutscene_active = false
