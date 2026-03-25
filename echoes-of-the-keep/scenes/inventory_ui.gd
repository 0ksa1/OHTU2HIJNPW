#
# Tämä ohjaa tiedosto ohjaa koko tavaraluettelon UI:ta.
#

extends Control

# Grid, jossa paneelit
@onready var inventory_container = $InventoryWindow/InventoryContainer

func _ready() -> void:
	hide()
	refresh_ui()

	if not Inventory.inventory_updated.is_connected(refresh_ui):
		Inventory.inventory_updated.connect(refresh_ui)

	var slots = inventory_container.get_children()
	for i in range(slots.size()):
		slots[i].gui_input.connect(_on_slot_gui_input.bind(i))


# Tähän klikkauksen käsittely, kun klikataan ruutua niin vaihdetaan niissä olevat tavarat keskenään
# kutsutaan myös swap_items joka on itse funktio itemejen paikkojen vaihdolle
func _on_slot_gui_input(event, i: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("slot clicked from ui: ", i)

		if Inventory.selected_slot == -1:
			Inventory.selected_slot = i
		else:
			Inventory.swap_items(Inventory.selected_slot, i)
			Inventory.selected_slot = -1

		refresh_ui()

func refresh_ui() -> void:
	#slotit
	var slots = inventory_container.get_children()

	for i in range(slots.size()):
		var slot_ui = slots[i]
		#indeksi itemeille
		slot_ui.slot_index = i
		#print("index: ", i) testi

		# jos slotteja on liikaa niin otetaan yksi pois
		if i >= Inventory.inventory.size():
			slot_ui.clear_slot()
			slot_ui.border_color()
			continue

		#itemin asetus slottiin
		var item_id = Inventory.inventory[i]

		if item_id == null:
			slot_ui.clear_slot()
		else:
			slot_ui.set_item(item_id)

#päivitetään aina ruudun väri
		slot_ui.border_color()
