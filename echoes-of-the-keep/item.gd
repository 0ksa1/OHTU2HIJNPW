# itemille UI näkymä
# funktio ottaa oikean itemin idn ja asettaa sen tavaraluettelon paneeliin
# Eli huolehditaan itemin piirrosta.


extends Control

@onready var icon: TextureRect = $TextureRect

func set_item(item_id: StringName) -> void:
	var data = ItemDB.ITEMS.get(item_id, null)
	# jos itemiä ei löydy tai se on väärä niin ei näytetä sitä.
	if data == null:
		icon.texture = null
		hide()
		return

	icon.texture = data["icon"]
	show()
