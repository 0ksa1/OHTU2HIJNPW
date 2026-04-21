extends Node2D

@export var door_id: String = "slime_room"
@export var locked: bool = true

@onready var blocker: StaticBody2D = $StaticBody2D

@onready var sfx_locked: AudioStreamPlayer2D = $SFX_Locked
@onready var interact_area: Area2D = $Area2D

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

func _play_locked_feedback() -> void:
	if sfx_locked:
		sfx_locked.pitch_scale = randf_range(0.95, 1.05)
		sfx_locked.play()


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
			_play_locked_feedback()
