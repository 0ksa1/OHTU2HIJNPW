extends Node2D

func _ready():
	global.current_scene = "dungeon_1"
	print(global.current_scene)
	

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
		get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
		global.finish_scene_change()
		print(global.current_scene)
		
