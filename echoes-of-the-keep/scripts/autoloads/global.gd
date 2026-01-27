extends Node

var current_scene = "game_scene"
var transition_scene = false

var player_exit_dungeon_posx = 0
var player_exit_dungeon_posy = 0
var player_exit_posx = 0
var player_exit_posy = 0

func finnish_scene_change():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "game_scene":
			current_scene = "dungeon_1"
			
		elif current_scene == "dungeon_1":
			current_scene = "game_scene"
