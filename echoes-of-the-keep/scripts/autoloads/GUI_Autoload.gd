extends CanvasLayer

var gui_components = [
	"res://scenes/pause_menu.tscn"
]

# Resoluutiot listana
var resolutions = {
	"640x360": Vector2i(640, 360),
	"1280x720": Vector2i(1280, 720),
	"1920x1080": Vector2i(1920, 1080),
	"2560x1440": Vector2i(2560, 1440),
}

var pause_menu: Node = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	for path in gui_components:
		var new_scene = (load(path) as PackedScene).instantiate()
		add_child(new_scene)
		new_scene.hide()
		
		if new_scene.name == "PauseMenu":
			pause_menu = new_scene

func _input(_event):
	if Input.is_action_just_pressed("escKey") and pause_menu:
		#print("esc press") testi
		if !get_tree().paused:
			pause_menu.pause()
		else:
			pause_menu.esc_back_or_resume()

# Fullscreen on/off
	if Input.is_action_just_pressed("fullscreen"):
		#print("fullscreen press") testi
		if get_window().mode == Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
		else:
			get_window().mode = Window.MODE_FULLSCREEN

#Funktio joka siirtää ruudun aina keskelle resoluution vaihdon jälkeen
func center_window():
	var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() /2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(screen_center - window_size/2)
