extends Control

@onready var inventory_container = $InventoryWindow/InventoryContainer

func _ready() -> void:
	hide()
	refresh_ui()

	if not Inventory.inventory_updated.is_connected(refresh_ui):
		Inventory.inventory_updated.connect(refresh_ui)

func refresh_ui() -> void:
	var slots = inventory_container.get_children()

	for i in range(slots.size()):
		var slot_ui = slots[i]

		if i >= Inventory.inventory.size():
			slot_ui.clear_slot()
			continue

		var item_id = Inventory.inventory[i]

		if item_id == null:
			slot_ui.clear_slot()
		else:
			slot_ui.set_item(item_id)
