extends CharacterBody2D

@export var mov_speed : float = 150
var character_direction : Vector2

func _physics_process(delta) :
	character_direction.x = Input.get_axis("move_left", "move_right")
	character_direction.y = Input.get_axis("move_up", "move_down")
	character_direction = character_direction.normalized()
	
	# kääntyminen
	if character_direction.x > 0 : %sprite.flip_h = false
	elif character_direction.x < 0 : %sprite.flip_h = true
	
	if character_direction:
		velocity = character_direction * mov_speed
		if %sprite.animation != "running": %sprite.animation = "running"
	else:
		velocity = velocity.move_toward(Vector2.ZERO, mov_speed)
		if %sprite.animation != "Idle" : %sprite.animation = "Idle"
		
	move_and_slide()
