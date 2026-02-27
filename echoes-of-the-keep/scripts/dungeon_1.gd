extends Node2D

@onready var player: Node2D = $player
@onready var cam_dungeon: Camera2D = $player/dungeon_camera
@onready var cam_game: Camera2D = $player/game_scene_camera
@onready var spawn: Marker2D = $Spawn

var switching_scene: bool = false


func _ready() -> void:
	# nyt ollaan dungeonissa
	global.current_scene = "dungeon_1"
	global.transition_scene = false

	# spawn player markerin kohtaan
	if is_instance_valid(spawn) and is_instance_valid(player):
		player.global_position = spawn.global_position

	# varmista dungeon-kamera varmasti current
	call_deferred("_force_dungeon_camera")


func _force_dungeon_camera() -> void:
	await get_tree().process_frame

	if is_instance_valid(cam_game):
		cam_game.enabled = false

	if is_instance_valid(cam_dungeon):
		cam_dungeon.enabled = true
		cam_dungeon.make_current()
		cam_dungeon.limit_enabled = false   # <- PAKOTA pois aina
		if cam_dungeon.has_method("reset_smoothing"):
			cam_dungeon.reset_smoothing()



func _process(_delta: float) -> void:
	change_scene()


func _on_exit_bridge_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = true


func _on_exit_bridge_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = false


func change_scene() -> void:
	if switching_scene:
		return

	if global.transition_scene == true:
		switching_scene = true
		global.transition_scene = false

		# merkkaa että poistutaan dungeonista
		global.current_scene = "dungeon_1"
		
		
		get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
		global.finish_scene_change()
