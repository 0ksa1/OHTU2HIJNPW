extends Control

@onready var icon: TextureRect = $TextureRect

func set_item(item_id: StringName) -> void:
	var data = ItemDB.ITEMS.get(item_id, null)
	if data == null:
		icon.texture = null
		hide()
		return

	icon.texture = data["icon"]
	show()
