extends Area2D

@onready var sprite = $Sprite2D
@export var next_scene: String = "res://scenes/hub1.tscn"
@onready var dialogue = $CanvasLayer/Dialogue
@export var item_id: StringName = &"potion"
@export var is_inventory_item: bool = true

var player_in_range: bool = false

func _ready():
	monitoring = true 
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		if is_inventory_item:
			collect_item()
		else:
			collect()

func collect():
	if not dialogue.d_active:
		sprite.visible = false
		player_in_range = false  

		dialogue.start("res://dialogue/item_dialogue1.json")

		await dialogue.dialogue_finished

		await get_tree().create_timer(0.2).timeout

		queue_free()
		get_tree().change_scene_to_file(next_scene)

func collect_item():
	var added := Inventory.add_item(item_id)
	if not added:
		print("Inventory full")
		return
	sprite.visible = false
	player_in_range = false
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
