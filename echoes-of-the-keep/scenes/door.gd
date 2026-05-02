extends Node2D

@export_enum("slime_room", "water_split_room", "boss_to_item") var door_id: String = "slime_room"
@export var locked: bool = true

@onready var blocker: StaticBody2D = $StaticBody2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx_open: AudioStreamPlayer2D = $SFX_Open 
@onready var dialogue = $CanvasLayer/Dialogue
@onready var player: Node2D = $"../player"

var player_in_range: bool = false

func _ready() -> void:
	add_to_group("doors")
	_apply_locked_state()

func _apply_locked_state() -> void:
	if blocker:
		blocker.visible = locked
		blocker.process_mode = Node.PROCESS_MODE_INHERIT
		blocker.set_deferred("collision_layer", blocker.collision_layer)
		var shape := blocker.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape:
			shape.disabled = not locked
			
func _can_unlock() -> bool:
	match door_id:
		"slime_room": return spawn_controller.rats_dead
		"water_split_room": return spawn_controller.bats_dead and spawn_controller.slimes_dead
		"boss_to_item": return spawn_controller.boss_dead
		_: return false
		
func _unlock() -> void:
	locked = false
	if sprite:
		sprite.visible = false
	var shape = blocker.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape:
		shape.set_deferred("disabled", true)
	if sfx_open:
		sfx_open.play()
	
func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		if locked:
			if _can_unlock():
				_unlock()
			else:
				_play_locked_dialogue()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = false

func _play_locked_dialogue() -> void:
	player.can_move = false
	dialogue.start("res://dialogue/door_dialogue.json")
	await dialogue.dialogue_finished
	player.can_move = true
