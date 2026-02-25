#
# Tavaraluettelolle autoload
#

extends Node

signal inventory_updated

var inventory: Array = []

func _ready() -> void:
	inventory.resize(12)
	for i in range(inventory.size()):
		inventory[i] = null
		
	add_item(&"potion")
	add_item(&"potion")
	add_item(&"potion")

func add_item(item_id: StringName) -> bool:
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item_id
			inventory_updated.emit()
			return true
	return false
