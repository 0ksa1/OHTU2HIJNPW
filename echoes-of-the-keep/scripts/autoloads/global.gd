extends Node

var current_scene = "hub1"
var last_scene = "hub1"
var next_scene = ""
var transition_scene = false

var player_start_posx: float = 526.0 
var player_start_posy: float = 566.0
var player_exit_dungeon_1_posx: float = -144.0
var player_exit_dungeon_1_posy: float = 21.0

var firstload = true

func finish_scene_change():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "hub1":
			last_scene = "hub1"
			current_scene = "dungeon_1"
			
		elif current_scene == "dungeon_1":
			last_scene = "dungeon_1"
			current_scene = "hub1"
