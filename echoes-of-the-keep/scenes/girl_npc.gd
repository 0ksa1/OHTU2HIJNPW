extends CharacterBody2D

var player = null
var player_in_chat_zone = false

@onready var dialogue = $CanvasLayer/Dialogue

func _on_chat_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		player_in_chat_zone = true

func _on_chat_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		player_in_chat_zone = false

func _process(delta):
	if player_in_chat_zone and Input.is_action_just_pressed("chat"):
		if not dialogue.d_active:
			dialogue.start()

func _on_dialogue_dialogue_finished():
	print("Dialogue finished")
