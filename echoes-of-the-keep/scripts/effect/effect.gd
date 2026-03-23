extends AnimatedSprite2D

func _ready():
	play("default")
	animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	queue_free()
