extends Control

signal dialogue_finished

@export_file("*.json") var d_file

var dialogue = []
var current_dialogue_id = 0
var d_active = false

func _ready():
	$NinePatchRect.visible = false
	
func start(dialogue_file: String = ""):
	if d_active:
		return
	d_active = true
	$NinePatchRect.visible = true
	var file_to_load = dialogue_file 
	dialogue = load_dialogue(file_to_load)
	current_dialogue_id = -1
	next_script()

func load_dialogue(path: String):
	if not FileAccess.file_exists(path):
		push_error("Dialogue file not found: " + path)
		return []
	var file = FileAccess.open(path, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content
	
func _input(event):
	if event.is_action_pressed("interact"):
		if d_active:
			next_script()
			get_viewport().set_input_as_handled()
		


func next_script ():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		d_active = false
		$NinePatchRect.visible = false
		emit_signal("dialogue_finished")
		return
		
	$NinePatchRect/Name.text = dialogue[current_dialogue_id]['name']
	$NinePatchRect/Text.text = dialogue[current_dialogue_id]['text']
