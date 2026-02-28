extends Node2D  # root node of hub1.tscn

@onready var spawn = $PlayerSpawn
@onready var player: Node2D = $player

func _ready():
	if spawn and player:
		player.global_position = spawn.global_position
