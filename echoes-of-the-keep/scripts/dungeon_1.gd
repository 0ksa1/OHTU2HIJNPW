extends Node2D

@onready var player: Node2D = $player
# FIX: Points to the universal camera name inside the player
@onready var cam: Camera2D = $player/Camera2D 
@onready var spawn: Marker2D = $Spawn

var switching_scene: bool = false

func _ready() -> void:
	# 1. Setup scene state
	global.current_scene = "dungeon_1"
	global.transition_scene = false

	# 2. Spawn player at the marker position
	if is_instance_valid(spawn) and is_instance_valid(player):
		player.global_position = spawn.global_position

	# 3. Trigger camera wake-up
	call_deferred("_force_dungeon_camera")

func _force_dungeon_camera() -> void:
	await get_tree().process_frame

	# FIX: Use the universal 'cam' variable
	if is_instance_valid(cam):
		cam.enabled = true
		cam.make_current()
		cam.global_position = player.global_position
		cam.limit_enabled = false
		
		if cam.has_method("reset_smoothing"):
			cam.reset_smoothing()
	else:
		print("Error: Could not find Camera2D inside the player node!")

# REMOVED _process entirely to prevent the infinite scene-switch crash

func _on_exit_bridge_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.next_scene = "res://scenes/hub1.tscn"
		global.transition_scene = true
		# TRIGGER the change immediately on contact
		change_scene()

func _on_exit_bridge_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global.next_scene = "res://scenes/hub1.tscn"
		global.transition_scene = false

func change_scene() -> void:
	if switching_scene:
		return

	if global.transition_scene == true:
		switching_scene = true

		# TÄRKEÄ: merkkaa että poistutaan game_scenestä
		global.current_scene = "dungeon_1"

		get_tree().change_scene_to_file("res://scenes/loading.tscn")
		
	if global.has_method("finish_scene_change"):
		global.finish_scene_change()
