# Funktiot ja nappien painallustoiminnot pausemenulle.
# Blur animation löytyy AnimationPlayer kohdasta, se sumentaa hetkeksi ruudun.
# Napit yms on kerätty VBoxContainerien sisään jotka ovat CenterContainerissa
# resume - restart - settings - controls - quit
# https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html
# Yllä olevalla sivulla on asiaa resoluutioista ja suositelluista kuvakooista

extends Control

#@onready var resume_button: Button = $CenterContainer/PanelContainer/VBoxContainer/ResumeButton
@onready var main_menu = $CenterContainer/PanelContainer/VBoxContainer
@onready var settings_panel = $CenterContainer/PanelContainer/SettingsPanel
@onready var resolutions_option_button = $CenterContainer/PanelContainer/SettingsPanel/VBoxContainer/HBoxContainer/OptionButton

func _ready():
	resolutions_option_button.item_selected.connect(_on_option_button_item_selected)
	hide()
	settings_panel.hide()
	main_menu.show()
	add_resolutions()
	update_button_values()
	#resume_button.pressed.connect(resume)

func add_resolutions():
	for r in GUI.resolutions:
		resolutions_option_button.add_item(r)

func update_button_values():
	var window_size_string = str(get_window().size.x, "x", get_window().size.y)
	var resolutions_index = GUI.resolutions.keys().find(window_size_string)
	resolutions_option_button.selected = resolutions_index

#tämä osuus ilmeisesti tökkii
#korjaan myöhemmin
func _on_option_button_item_selected(index):
	var key = resolutions_option_button.get_item_text(index)
	get_window().set_size(GUI.resolutions[key])
	

func open_settings():
	main_menu.hide()
	settings_panel.show()

func close_settings():
	settings_panel.hide()
	main_menu.show()

func resume():
	get_tree().paused = false
	print("RESUME pressed")
	$AnimationPlayer.play_backwards("blur_animation")
	hide()
	close_settings()

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur_animation")
	show()
	main_menu.show()
	settings_panel.hide()

# funktio, jolla voi palata taaksepäin escillä
func esc_back_or_resume():
	if settings_panel.visible:
		close_settings()
		return
	resume()

func _on_settings_button_pressed():
	open_settings()

func _on_back_button_pressed():
	close_settings()

#controls nappi, ei vielä tee mitään
func _on_controls_button_pressed() -> void:
	pass
	
	
func _on_restart_button_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_resume_button_pressed() -> void:
	resume()
