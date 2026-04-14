# Itemejen tiedot tulee tänne


#item database

extends Node

const ITEMS := {
	&"potion": {
		#sisältää tiedot kuvalle, tyypille, efektille ja määrälle mitä tavara tekee
		"icon": preload("res://art/items/potion-0002.png"),
		"type": "consumable",
		"effect": "heal",
		"amount": 25
	},
	#artifakti
	&"teleport_flask": {
		"icon": preload("res://art/items/bottle.png"),
		"type": "consumable",
		"effect": "teleport"
	}
}
