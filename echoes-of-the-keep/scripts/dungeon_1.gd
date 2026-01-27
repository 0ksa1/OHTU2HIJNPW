extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	change_scene()


func _on_exit_bridge_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = true


func _on_exit_bridge_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = false

func change_scene():
	if global.transition_scene == true:
		if global.current_scene == "dungeon_1":
			get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
			#global.finnish_scene_change()
		else:
			get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
