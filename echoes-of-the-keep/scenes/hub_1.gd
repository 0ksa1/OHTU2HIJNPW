extends Node2D

var current_scene: String = "hub1"
var firstload: bool = true
var transition_scene: bool = false

@onready var player: Node2D = $player
# FIX: Find the camera INSIDE the player node
@onready var cam: Camera2D = $player/Camera2D

var switching_scene: bool = false
var entrance_active: bool = false

func _ready() -> void:
	# 1. Handle Spawn Position
	if global.firstload == true:
		player.position = Vector2(global.player_start_posx, global.player_start_posy)
	elif global.current_scene == "dungeon_1":
		player.position = Vector2(global.player_exit_dungeon_1_posx, global.player_exit_dungeon_1_posy)

	# 2. Set current scene name
	global.current_scene = "hub1"

	# 3. Force the camera to wake up
	call_deferred("_force_game_camera")

func _force_game_camera() -> void:
	await get_tree().process_frame

	if is_instance_valid(cam):
		cam.enabled = true
		cam.limit_enabled = false
		cam.make_current()
		cam.global_position = player.global_position
		if cam.has_method("reset_smoothing"):
			cam.reset_smoothing()

func _on_dungeon_bridge_1_body_entered(body: Node2D) -> void:
	if body.has_method("player") and not switching_scene and global.dungeon_activated:
		global.next_scene = "res://scenes/dungeon_1.tscn"
		global.transition_scene = true
		# TRIGGER THE CHANGE HERE instead of in _process
		change_scene()

func _on_dungeon_bridge_1_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = false

func change_scene() -> void:
	if switching_scene:
		return
		
	switching_scene = true
	global.firstload = false
	
	# Set this to the current scene so the next scene knows where you came from
	global.current_scene = "hub1"

	get_tree().change_scene_to_file("res://scenes/loading.tscn")
	
	# If this function exists in your global script, call it
	if global.has_method("finish_scene_change"):
		global.finish_scene_change()
