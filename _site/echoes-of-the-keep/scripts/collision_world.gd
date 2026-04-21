extends Node2D

# piilotetaan ugly ass collision debug palikat käynnistäessä
@export var hide_in_game: bool = true
@export var debug_node_path: NodePath = ^"collision_tilemap"

func _ready() -> void:
	if hide_in_game:
		var n := get_node_or_null(debug_node_path)
		if n:
			n.visible = false
