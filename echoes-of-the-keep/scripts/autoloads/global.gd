extends Node

var current_scene = "game_scene"
var transition_scene = false

var player_exit_dungeon_posx = 129
var player_exit_dungeon_posy = -19
var player_start_posx = -90
var player_start_posy = 0

var firstload = true

func finnish_scene_change():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "game_scene":
			current_scene = "dungeon_1"
			
		elif current_scene == "dungeon_1":
			current_scene = "game_scene"
