extends Node2D

@export_enum("slime_room", "water_split_room", "boss_to_item") var door_id: String = "slime_room"
@export var locked: bool = true

@onready var blocker: StaticBody2D = $StaticBody2D

@onready var sfx_open: AudioStreamPlayer2D = $SFX_Open
@onready var interact_area: Area2D = $Area2D
@onready var dialogue = $CanvasLayer/Dialogue
@onready var player: Node2D = $"../player"



var player_inside: bool = false

func _ready() -> void:
	add_to_group("doors")
	_apply_locked_state()

func _apply_locked_state() -> void:
	if blocker:
		blocker.visible = locked
		blocker.process_mode = Node.PROCESS_MODE_INHERIT
		# tärkein: collider päälle/pois
		blocker.set_deferred("collision_layer", blocker.collision_layer) # no-op mutta safe
		# helpoin: disabloi shape
		var shape := blocker.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape:
			shape.disabled = not locked

func unlock() -> void:
	locked = false
	_apply_locked_state()
	# tänne myöhemmin open-ääni/animaatio

func _play_open_feedback() -> void:
	if sfx_open:
		sfx_open.pitch_scale = randf_range(0.95, 1.05)
		sfx_open.play()

func _on_body_entered(body: Node) -> void:
	if body.has_method("player"):
		player_inside = true

func _on_body_exited(body: Node) -> void:
	if body.has_method("player"):
		player_inside = false


var player_in_range := false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if not player_in_range:
		return

	if event.is_action_pressed("interact"):
		if locked:
			if _can_unlock():
				unlock()
				_play_open_feedback()
			else:
				player.can_move = false
				dialogue.start("res://dialogue/door_dialogue.json")
				await dialogue.dialogue_finished
				player.can_move = true

func _can_unlock() -> bool:
	match door_id:
		"slime_room":
			return spawn_controller.rats_dead
		"water_split_room":
			return spawn_controller.bats_dead and spawn_controller.slimes_dead
		"boss_to_item":
			return spawn_controller.boss_dead
		_:
			return false
