#
# Tavaraluettelolle autoload
# eli autoload siis säilyttää tiedon scenejen välillä mitä tavaraluettelossa milloinkin on

extends Node

signal inventory_updated

var inventory: Array = []

func _ready() -> void:
	#inventory alustus kun 12 paneelia
	inventory.resize(12)
	for i in range(inventory.size()):
		inventory[i] = null
		
	#testi jolla lisäsin itemejä tavaraluetteloon
	#add_item(&"potion")
	#add_item(&"potion") testi
	#add_item(&"potion")

func add_item(item_id: StringName) -> bool:
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item_id
			inventory_updated.emit()
			return true
	return false

# tähän voisi lisätä sitten remove item kun potion tms käytetään

# ehkä myös tarkistus funktio onko pelaajalla itemi niin voi vaikka avata seuraavan dungeonin tms?
