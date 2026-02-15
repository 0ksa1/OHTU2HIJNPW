extends Node

@export var entry_volume_db: float = 1.0
@export var ambient_volume_db: float = 1.0
@export var fade_in_time: float = 0.6
@export var play_entry_on_ready: bool = true

@onready var entry: AudioStreamPlayer2D = $Entry_Sting
@onready var ambient: AudioStreamPlayer2D = $Ambient_Drips

func _ready() -> void:
	# Ambient ei käynnisty heti
	ambient.stop()
	ambient.volume_db = -80.0

	# Kun entry loppuu -> ambient päälle
	if not entry.finished.is_connected(_on_entry_finished):
		entry.finished.connect(_on_entry_finished)

	if play_entry_on_ready:
		_play_entry_then_ambient()
	else:
		_start_ambient()

func _play_entry_then_ambient() -> void:
	if entry:
		entry.volume_db = entry_volume_db
		entry.play()
	else:
		# Jos entry puuttuu, aloitetaan ambient suoraan
		_start_ambient()

func _on_entry_finished() -> void:
	_start_ambient()

func _start_ambient() -> void:
	if not ambient:
		return
	ambient.play()
	_fade_to(ambient, ambient_volume_db, fade_in_time)

func _fade_to(player: AudioStreamPlayer2D, target_db: float, time_sec: float) -> void:
	var tw := create_tween()
	tw.tween_property(player, "volume_db", target_db, time_sec)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
