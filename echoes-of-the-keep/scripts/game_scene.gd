extends Node2D

@onready var player: Node2D = $player

# piilotetaan collision-layer (kuten ennen)
@onready var collision_layer: TileMapLayer = $collision_tilemap

# käytetään bounds-laskentaan background-layeria
@onready var bounds_layer: TileMapLayer = $background_tilemap

@onready var cam: Camera2D = $player/game_scene_camera


func _ready() -> void:
	collision_layer.visible = false

	# Spawn logic (säilytetään)
	if global.firstload == true:
		player.position.x = global.player_start_posx
		player.position.y = global.player_start_posy
	elif global.current_scene == "dungeon_1":
		player.position.x = global.player_exit_dungeon_1_posx
		player.position.y = global.player_exit_dungeon_1_posy

	global.current_scene = "game_scene"

	# Varmista oikea kamera
	if cam:
		cam.enabled = true
		cam.make_current()

	# Aseta limitit background-layerin käytetyn alueen mukaan
	_apply_camera_limits_from_tilemap_layer(bounds_layer, cam)


func _process(_delta: float) -> void:
	change_scene()


func _on_dungeon_bridge_1_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = true


func _on_dungeon_bridge_1_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = false


func change_scene() -> void:
	if global.transition_scene == true:
		global.firstload = false
		get_tree().change_scene_to_file("res://scenes/dungeon_1.tscn")
		global.finish_scene_change()


# -------------------------
# Camera limits from TileMapLayer (world-correct)
# -------------------------

func _apply_camera_limits_from_tilemap_layer(layer: TileMapLayer, camera: Camera2D) -> void:
	if layer == null or camera == null:
		push_warning("Camera limits: TileMapLayer or Camera missing.")
		return

	var used: Rect2i = layer.get_used_rect()
	if used.size == Vector2i.ZERO:
		push_warning("Camera limits: TileMapLayer used rect is empty.")
		return

	var ts: TileSet = null
	if layer.has_method("get_tileset"):
		ts = layer.get_tileset()
	elif "tile_set" in layer:
		ts = layer.tile_set
	elif "tileset" in layer:
		ts = layer.tileset

	if ts == null:
		push_warning("Camera limits: Could not find TileSet from TileMapLayer.")
		return

	var tile_size: Vector2i = ts.tile_size

	# Local pixel corners
	var local_left_top := Vector2(
		used.position.x * tile_size.x,
		used.position.y * tile_size.y
	)
	var local_right_bottom := Vector2(
		(used.position.x + used.size.x) * tile_size.x,
		(used.position.y + used.size.y) * tile_size.y
	)

	# Convert to world
	var world_left_top: Vector2 = layer.to_global(local_left_top)
	var world_right_bottom: Vector2 = layer.to_global(local_right_bottom)

	camera.limit_left = int(minf(world_left_top.x, world_right_bottom.x))
	camera.limit_top = int(minf(world_left_top.y, world_right_bottom.y))
	camera.limit_right = int(maxf(world_left_top.x, world_right_bottom.x))
	camera.limit_bottom = int(maxf(world_left_top.y, world_right_bottom.y))
