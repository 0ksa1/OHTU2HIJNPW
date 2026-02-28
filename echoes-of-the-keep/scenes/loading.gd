extends Node2D


@onready var progres = $ProgressBar
@export var next_scene_path = global.next_scene
var progress: Array[float] = []
@onready var sprite = %character
var run_speed = 500.0

func _ready() -> void:
	print(global.next_scene)
	$character.play()
	ResourceLoader.load_threaded_request(next_scene_path)
	
func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var pct = progress[0] * 100
			progres.value = pct
		ResourceLoader.THREAD_LOAD_LOADED:
			sprite.position.x += run_speed * delta
			if sprite.position.x > get_viewport_rect().size.x:
				print(next_scene_path)
				var scene = ResourceLoader.load_threaded_get(next_scene_path)
				get_tree().change_scene_to_packed(scene)
		
	
