extends Node2D

@onready var player: Node2D = $player
@onready var cam_game: Camera2D = $player/game_scene_camera
@onready var cam_dungeon: Camera2D = $player/dungeon_camera

var switching_scene: bool = false


func _ready() -> void:
	# Spawn/return position
	if global.firstload == true:
		player.position.x = global.player_start_posx
		player.position.y = global.player_start_posy
	elif global.current_scene == "dungeon_1":
		player.position.x = global.player_exit_dungeon_1_posx
		player.position.y = global.player_exit_dungeon_1_posy

	# Nyt ollaan game_scenessä
	global.current_scene = "game_scene"

	# FORCE correct camera one frame after load
	call_deferred("_force_game_camera")


func _force_game_camera() -> void:
	await get_tree().process_frame

	if is_instance_valid(cam_dungeon):
		cam_dungeon.enabled = false

	if is_instance_valid(cam_game):
		cam_game.enabled = true
		cam_game.make_current()
		if cam_game.has_method("reset_smoothing"):
			cam_game.reset_smoothing()


func _process(_delta: float) -> void:
	change_scene()


func _on_dungeon_bridge_1_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.next_scene = "res://scenes/dungeon_1.tscn"
		global.transition_scene = true
		


func _on_dungeon_bridge_1_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = false


func change_scene() -> void:
	if switching_scene:
		return

	if global.transition_scene == true:
		switching_scene = true
		global.firstload = false

		# TÄRKEÄ: merkkaa että poistutaan game_scenestä
		global.current_scene = "game_scene"

		get_tree().change_scene_to_file("res://scenes/loading.tscn")
		global.finish_scene_change()
