# slotin tyhjennys ja täyttö
#
#

extends Panel

var ItemClass = preload("res://item.tscn")
var item = null

func _ready() -> void:
	clear_slot()

func clear_slot() -> void:
	if item != null:
		item.queue_free()
		item = null

func set_item(item_id: StringName) -> void:
	clear_slot()
	item = ItemClass.instantiate()
	add_child(item)

	if item is Control:
		item.anchor_left = 0.0
		item.anchor_top = 0.0
		item.anchor_right = 1.0
		item.anchor_bottom = 1.0
		item.offset_left = 0
		item.offset_top = 0
		item.offset_right = 0
		item.offset_bottom = 0

	item.set_item(item_id)
