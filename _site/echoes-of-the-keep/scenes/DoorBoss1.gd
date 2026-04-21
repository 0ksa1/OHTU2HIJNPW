extends Node2D

@export var interact_action: StringName = &"interact"
@export var open_delay: float = 0.15

# Polku spawn-pointtiin *dungeon_1-scenessä*.
# Oletus: boss-spawn on dungeon_1 rootin alla nimellä "BossSpawn".
@export var boss_spawn_path: NodePath = NodePath("/root/dungeon_1/BossSpawn")

@onready var interact_area: Area2D = $Area2D
@onready var sfx_open: AudioStreamPlayer2D = $SFX_Open

var _player_in_range := false
var _busy := false

func _ready() -> void:
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if _busy or not _player_in_range:
		return

	if event.is_action_pressed(interact_action):
		_busy = true
		_open_and_teleport()

func _open_and_teleport() -> void:
	if sfx_open:
		sfx_open.play()

	await get_tree().create_timer(open_delay).timeout

	# Hae spawnpoint
	var spawn := get_node_or_null(boss_spawn_path) as Node2D
	if spawn == null:
		push_error("DoorBoss1: BossSpawn not found at path: %s" % [str(boss_spawn_path)])
		_busy = false
		return

	# Hae player (sun mukaan dungeon_1:ssä polulla $player)
	var player := get_tree().current_scene.get_node_or_null("player") as Node2D
	if player == null:
		push_error("DoorBoss1: player not found at current_scene path 'player'")
		_busy = false
		return

	# Siirrä pelaaja
	player.global_position = spawn.global_position

	# Vinkki: jos käytät CharacterBody2D:llä velocitya, nollaa se
	if player is CharacterBody2D:
		(player as CharacterBody2D).velocity = Vector2.ZERO

	_busy = false

func _on_body_entered(body: Node) -> void:
	if body and body.has_method("player"):
		_player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body and body.has_method("player"):
		_player_in_range = false
