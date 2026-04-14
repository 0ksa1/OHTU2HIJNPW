# Itemejen tiedot tulee tänne


#item database

extends Node

const ITEMS := {
	&"potion": {
		#sisältää tiedot kuvalle, tyypille, efektille ja määrälle mitä tavara tekee, kuvaus
		"icon": preload("res://art/items/potion-0002.png"),
		"type": "consumable",
		"effect": "heal",
		"amount": 33,
		"description": "A simple healing potion that restores a small amount of vitality."
	},
	#artifakti
	&"teleport_flask": {
		"icon": preload("res://art/items/bottle.png"),
		"type": "consumable",
		"effect": "teleport",
		"description": "artifact
		
		teleports player when picked up"
	}
}
