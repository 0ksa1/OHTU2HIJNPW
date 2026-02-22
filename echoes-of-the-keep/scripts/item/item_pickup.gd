extends Area2D

@onready var sprite = $Sprite2D
var player_in_range: bool = false

func _ready():
	monitoring = true 
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		collect()

func collect():
	queue_free() 

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
