extends Node2D

func _ready() -> void:
	$collision_tilemap.visible = false
	
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
		if global.current_scene == "game_scene":
			get_tree().change_scene_to_file("res://scenes/dungeon_1.tscn")
			global.finnish_scene_change()
		else:
			get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
			
