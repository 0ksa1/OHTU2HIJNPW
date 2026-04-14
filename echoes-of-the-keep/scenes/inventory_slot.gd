# slotin tyhjennys ja täyttö
#
#

extends Panel

var ItemClass = preload("res://scenes/item/item.tscn")
var item = null
var slot_index: int = -1

func _ready() -> void:
	#print("inventory slot testi")
	clear_slot()
	border_color()
	#hiirellä hoveraus itemin kuvaukselle
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func clear_slot() -> void:
	if item != null:
		item.queue_free()
		item = null

func set_item(item_id: StringName) -> void:
	clear_slot()
	item = ItemClass.instantiate()
	add_child(item)


	if item is Control:
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.anchor_left = 0.0
		item.anchor_top = 0.0
		item.anchor_right = 1.0
		item.anchor_bottom = 1.0
		item.offset_left = 0
		item.offset_top = 0
		item.offset_right = 0
		item.offset_bottom = 0

	item.set_item(item_id)

#funktio itse slotin värin vaihtoon
func border_color() -> void:
	if Inventory.selected_slot == slot_index:
		modulate = Color.ANTIQUE_WHITE
	else:
		modulate = Color.WHITE

#hiirellä hoveraus funktiot tavaroiden kuvauksille
func _on_mouse_entered() -> void:
	#indeksin tarkistus
	if slot_index == -1:
		return
	if slot_index >= Inventory.inventory.size():
		return

	#haetaan itemin id
	var item_id = Inventory.inventory[slot_index]
	if item_id == null:
		return

	var data = ItemDB.ITEMS.get(item_id, null)
	if data == null:
		return

	# haetaan node ja näytetään item databasessa oleva kuvaus
	var tooltip = get_tree().get_first_node_in_group("item_tooltip")
	if tooltip:
		tooltip.show_tooltip(data.get("description", ""), get_global_mouse_position())

# funktio kuvauksen poistamiseen kun hiiri ei ole item slotin päällä
func _on_mouse_exited() -> void:
	var tooltip = get_tree().get_first_node_in_group("item_tooltip")
	if tooltip:
		tooltip.hide_tooltip()
