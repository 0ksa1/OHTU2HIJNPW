#
# Tavaraluettelolle autoload
# eli autoload siis säilyttää tiedon scenejen välillä mitä tavaraluettelossa milloinkin on

extends Node

signal inventory_updated

var inventory: Array = []

# valitun slotin ns indeksi, -1 sillä mitään slottia ei ole vielä valittuna
var selected_slot: int = -1

func _ready() -> void:
	#inventory alustus kun 12 paneelia
	inventory.resize(12)
	for i in range(inventory.size()):
		inventory[i] = null
		
	#testi jolla lisäsin itemejä tavaraluetteloon
	add_item(&"potion")
	add_item(&"potion") 
	add_item(&"teleport_flask") 
	#add_item(&"potion")

#itemin lisäys
func add_item(item_id: StringName) -> bool:
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item_id
			inventory_updated.emit()
			return true
	return false

#kahden itemin paikkojen vaihto, vaihdetaan indekseissä olevat itemit päittäin
func swap_items(index_a: int, index_b: int) -> void:
	if index_a < 0 or index_a >= inventory.size():
		return
	if index_b < 0 or index_b >= inventory.size():
		return

	var temp = inventory[index_a]
	inventory[index_a] = inventory[index_b]
	inventory[index_b] = temp

	inventory_updated.emit()


# tavaraluettelosta poistaminen
func remove_item(index: int) -> void:
	if index < 0 or index >= inventory.size():
		return

	inventory[index] = null
	inventory_updated.emit()

func use_item(index: int, player) -> void:
#tarkistus onko indeksi inventoryn rajojen mukainen
	if index < 0 or index >= inventory.size():
		return

# haetaan itemin id ja jos slotissa ei ole kyseistä itemiä niin lopetetaan
	var item_id = inventory[index]
	if item_id == null:
		return

#itemin tiedot
	var data = ItemDB.ITEMS.get(item_id, null)
	if data == null:
		return

#tyyppi
	var item_type = data.get("type", "")
	var effect = data.get("effect", "")

#itse itemin käyttö
	if item_type == "consumable":
		if effect == "heal":
			var amount = data.get("amount", 0)
			player.heal(amount)
			player.play_potion_sound()
			remove_item(index)

		elif effect == "teleport":
			print("Teleport item used")
			#ei poisteta artifaktia
			#remove_item(index)

# ehkä myös tarkistus funktio onko pelaajalla itemi niin voi vaikka avata seuraavan dungeonin tms?
