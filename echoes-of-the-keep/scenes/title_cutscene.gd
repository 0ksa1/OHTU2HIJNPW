extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GUI:
		var healthbar = GUI.get_node_or_null("HUD/Healthbar")
		var stamina_bar = GUI.get_node_or_null("HUD/Staminabar")
		var health_label = GUI.get_node_or_null("HUD/HealthLabel")
		var stamina_label = GUI.get_node_or_null("HUD/StaminaLabel")

		if healthbar:
			healthbar.hide()
		if stamina_bar:
			stamina_bar.hide()
		if health_label:
			health_label.hide()
		if stamina_label:
			stamina_label.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName):
	if anim_name == "title_animation":
		get_tree().change_scene_to_file("res://scenes/hub1.tscn")
