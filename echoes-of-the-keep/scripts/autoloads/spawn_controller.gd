extends Node

var rats_dead: bool = false
var bats_dead: bool = false
var slimes_dead: bool = false
var boss_dead: bool = false

var current_spawn: String = "DefaultSpawn"

func update_spawn():
	if bats_dead and slimes_dead:
		current_spawn = "dungeon_bossroom_sp"
	elif rats_dead:
		current_spawn = "dungeon_room2_sp"
	else:
		current_spawn = "dungeon_room1_sp"
		
func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
