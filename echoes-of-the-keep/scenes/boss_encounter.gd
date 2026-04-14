extends Node2D

@export var boss_scene: PackedScene
@export var intro_start_delay: float = 0.5
@export var intro_hold_time: float = 1.2
@export var boss_jump_duration: float = 0.8
@export var boss_name_text: String = "Forgotten Slime"

var encounter_started: bool = false
var boss_instance: Node2D = null

@onready var trigger_area: Area2D = $TriggerArea
@onready var boss_spawn_point: Marker2D = $BossSpawnPoint
@onready var boss_pond_spawn_point: Marker2D = $BossPondSpawnPoint
@onready var camera_focus_point: Marker2D = $CameraFocusPoint
@onready var boss_container: Node2D = $BossContainer
@onready var intro_sfx_player: AudioStreamPlayer = $IntroSfxPlayer
@onready var boss_music_player: AudioStreamPlayer = $BossMusicPlayer
@onready var cutscene_manager = $"../CutsceneManager"
@onready var boss_name_ui: CanvasLayer = $"../BossNameUI"
@onready var boss_health_ui: CanvasLayer = $"../BossHealthUI"

func _ready() -> void:
	if trigger_area == null:
		push_error("BossEncounter: TriggerArea-nodea ei löytynyt.")
		return

	trigger_area.body_entered.connect(_on_trigger_area_body_entered)

	print("BossEncounter valmis")
	print("BossEncounter: boss_scene = ", boss_scene)

func _on_trigger_area_body_entered(body: Node2D) -> void:
	print("BossEncounter: Triggeriin tuli -> ", body.name)

	if encounter_started:
		print("BossEncounter: encounter on jo käynnissä")
		return

	if not body.is_in_group("player"):
		print("BossEncounter: body ei ole player groupissa")
		return

	encounter_started = true
	trigger_area.monitoring = false
	print("BossEncounter: Pelaaja havaittu triggerissä")

	call_deferred("_start_intro")

func _start_intro() -> void:
	print("BossEncounter: intro alkaa")

	await get_tree().create_timer(intro_start_delay).timeout
	play_intro_sfx()

	if cutscene_manager != null and cutscene_manager.has_method("play_pan_to"):
		await cutscene_manager.play_pan_to(camera_focus_point.global_position, intro_hold_time)

	spawn_boss_in_pond()
	await play_boss_intro_jump()

	var name_time: float = 6.5

	if intro_sfx_player != null and intro_sfx_player.stream != null and intro_sfx_player.playing:
		var length: float = intro_sfx_player.stream.get_length()
		var elapsed: float = intro_sfx_player.get_playback_position()
		var remaining: float = max(0.0, length - elapsed)
		var wait_before_name: float = max(0.0, remaining - name_time)

		await get_tree().create_timer(wait_before_name).timeout

	# Näytä cinematic-nimi VAIN kerran
	show_boss_name()
	await get_tree().create_timer(name_time).timeout
	await hide_boss_name()

	# Odota että intro-audio loppuu
	if intro_sfx_player.playing:
		await intro_sfx_player.finished

	# Kamera takaisin pelaajaan
	if cutscene_manager != null and cutscene_manager.has_method("return_to_player"):
		await cutscene_manager.return_to_player()

	# Vasta nyt HP UI näkyviin
	setup_boss_health_ui()

	start_boss_music()
	
	if boss_instance != null and boss_instance.has_method("start_fight"):
		boss_instance.call("start_fight")

	print("BossEncounter: intro loppui")

func play_intro_sfx() -> void:
	if intro_sfx_player == null:
		push_warning("BossEncounter: IntroSfxPlayer puuttuu.")
		return

	if intro_sfx_player.stream == null:
		push_warning("BossEncounter: IntroSfxPlayerilta puuttuu stream.")
		return

	if not intro_sfx_player.playing:
		intro_sfx_player.play()
		print("BossEncounter: intro sfx played")

func start_boss_music() -> void:
	if boss_music_player == null:
		push_warning("BossEncounter: BossMusicPlayer puuttuu.")
		return

	if boss_music_player.stream == null:
		push_warning("BossEncounter: BossMusicPlayerilta puuttuu stream.")
		return

	if not boss_music_player.playing:
		boss_music_player.play()
		print("BossEncounter: boss music started")

func spawn_boss_in_pond() -> void:
	print("BossEncounter: spawn_boss_in_pond() kutsuttu")

	if boss_scene == null:
		push_error("BossEncounter: boss_scene puuttuu Inspectorista.")
		return

	if boss_pond_spawn_point == null:
		push_error("BossEncounter: BossPondSpawnPoint-nodea ei löytynyt.")
		return

	if boss_container == null:
		push_error("BossEncounter: BossContainer-nodea ei löytynyt.")
		return

	var inst = boss_scene.instantiate()
	print("BossEncounter: instansioitu boss -> ", inst)

	if inst == null:
		push_error("BossEncounter: boss_sceneä ei voitu instansoida.")
		return

	boss_instance = inst as Node2D
	if boss_instance == null:
		push_error("BossEncounter: instansioitu boss ei ole Node2D.")
		return

	boss_container.add_child(boss_instance)
	boss_instance.global_position = boss_pond_spawn_point.global_position

	if boss_instance.has_signal("boss_died"):
		boss_instance.connect("boss_died", Callable(self, "_on_boss_died"))

	print("BossEncounter: Boss spawnattu lätäkköön -> ", boss_pond_spawn_point.global_position)
	print("BossEncounter: Boss actual global_position -> ", boss_instance.global_position)

func play_boss_intro_jump() -> void:
	if boss_instance == null:
		push_warning("BossEncounter: boss_instance puuttuu jump-introsta.")
		return

	if boss_spawn_point == null:
		push_error("BossEncounter: BossSpawnPoint-nodea ei löytynyt.")
		return

	if boss_instance.has_method("play_intro_jump"):
		print("BossEncounter: kutsutaan play_intro_jump()")
		boss_instance.call("play_intro_jump")

	var tween = create_tween()
	tween.tween_property(
		boss_instance,
		"global_position",
		boss_spawn_point.global_position,
		boss_jump_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished

	print("BossEncounter: tween finished, vaihdetaan idleen")

	if boss_instance.has_method("play_idle_after_intro"):
		boss_instance.call("play_idle_after_intro")

	print("BossEncounter: Boss intro jump valmis")

func show_boss_name() -> void:
	if boss_name_ui == null:
		push_warning("BossEncounter: BossNameUI puuttuu.")
		return

	print("BossEncounter: show_boss_name() kutsuttu")

	if boss_name_ui.has_method("show_name"):
		boss_name_ui.call("show_name", boss_name_text)

func hide_boss_name() -> void:
	if boss_name_ui == null:
		return

	print("BossEncounter: hide_boss_name() kutsuttu")

	if boss_name_ui.has_method("hide_name"):
		await boss_name_ui.hide_name()

func setup_boss_health_ui() -> void:
	if boss_instance == null:
		return

	if boss_health_ui == null:
		push_warning("BossEncounter: BossHealthUI puuttuu.")
		return

	if boss_health_ui.has_method("show_bar") and "max_hp" in boss_instance:
		boss_health_ui.call("show_bar", boss_name_text, boss_instance.max_hp)

	if boss_instance.has_signal("health_changed"):
		boss_instance.connect("health_changed", Callable(self, "_on_boss_health_changed"))

func _on_boss_health_changed(current_hp: int, max_hp: int) -> void:
	if boss_health_ui == null:
		return

	if boss_health_ui.has_method("update_health"):
		boss_health_ui.call("update_health", current_hp)

func _on_boss_died() -> void:
	if boss_music_player != null and boss_music_player.playing:
		boss_music_player.stop()
		print("BossEncounter: boss music stopped")

	if boss_health_ui != null and boss_health_ui.has_method("hide_bar"):
		boss_health_ui.call("hide_bar")
