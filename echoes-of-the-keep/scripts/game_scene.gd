extends Node2D

func _ready() -> void:
	
	$collision_tilemap.visible = false
	
	if global.firstload == true:
		$player.position.x = global.player_start_posx
		$player.position.y = global.player_start_posy
	elif global.current_scene == "dungeon_1":
		$player.position.x = global.player_exit_dungeon_1_posx
		$player.position.y = global.player_exit_dungeon_1_posy
	global.current_scene = "game_scene"
	
func _process(delta):
	change_scene()


func _on_dungeon_bridge_1_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = true


func _on_dungeon_bridge_1_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = false

func change_scene():
	if global.transition_scene == true:
		global.firstload = false
		get_tree().change_scene_to_file("res://scenes/dungeon_1.tscn")
		global.finish_scene_change()
