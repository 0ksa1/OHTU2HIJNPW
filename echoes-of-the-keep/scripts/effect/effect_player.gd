extends Node

const IMPACT_VIOLET = preload("res://scenes/effects/impact_effect.tscn")

func play_impact(pos: Vector2):
	var effect = IMPACT_VIOLET.instantiate()
	effect.global_position = pos
	get_tree().current_scene.add_child(effect)
	effect.play("default") 
	
	effect.animation_finished.connect(effect.queue_free)
