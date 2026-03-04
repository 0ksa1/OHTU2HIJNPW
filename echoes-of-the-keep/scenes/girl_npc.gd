extends CharacterBody2D

var player = null
var player_in_chat_zone = false

@onready var dialogue = $CanvasLayer/Dialogue

func _on_chat_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_chat_zone = true

func _on_chat_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_chat_zone = false
		
func _input(event):
	if event.is_action_pressed("interact"):
		if player_in_chat_zone and not dialogue.d_active:
			_start_dialoque()
			

func _start_dialoque():
	dialogue.start("res://dialogue/girl_dialogue1.json")

func _on_dialogue_dialogue_finished():
	print("Dialogue finished")
