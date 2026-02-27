extends Node

var current_scene = "game_scene"
var last_scene = "game_scene"
var next_scene = ""
var transition_scene = false

var player_exit_dungeon_1_posx = 129
var player_exit_dungeon_1_posy = -19
var player_start_posx = -90
var player_start_posy = 0

var firstload = true

func finish_scene_change():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "game_scene":
			last_scene = "game_scene"
			current_scene = "dungeon_1"
			
		elif current_scene == "dungeon_1":
			last_scene = "dungeon_1"
			current_scene = "game_scene"
