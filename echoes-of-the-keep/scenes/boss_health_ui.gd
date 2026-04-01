extends CanvasLayer

@onready var boss_label: Label = $MarginContainer/VBoxContainer/BossLabel
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar

func _ready() -> void:
	hide_bar()

func show_bar(boss_name: String, max_hp: int) -> void:
	if boss_label == null or health_bar == null:
		push_error("BossHealthUI: BossLabel tai HealthBar puuttuu.")
		return

	boss_label.visible = true
	boss_label.text = boss_name

	health_bar.min_value = 0
	health_bar.max_value = max_hp
	health_bar.value = max_hp

	visible = true
	print("BossHealthUI: show_bar -> ", boss_name, " | max_hp = ", max_hp)

func update_health(current_hp: int) -> void:
	if health_bar == null:
		push_error("BossHealthUI: HealthBar puuttuu.")
		return

	health_bar.value = current_hp
	print("BossHealthUI: update_health -> ", current_hp)

func hide_bar() -> void:
	visible = false
	print("BossHealthUI: hide_bar")
