extends Control

func _ready():
	hide()

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur_animation")
	hide()

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur_animation")
	show()

func testEsc():
	if Input.is_action_just_pressed("escKey") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("escKey") and get_tree().paused == true:
		resume()

func _on_resume_button_pressed():
	resume()
func _on_restart_button_pressed():
	resume()
	get_tree().reload_current_scene()
func _on_quit_button_pressed():
	get_tree().quit()

func _process(delta):
	testEsc()
