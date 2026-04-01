extends CanvasLayer

@onready var name_label: Label = $NameLabel

func _ready() -> void:
	visible = false
	if name_label != null:
		name_label.visible = false
		name_label.modulate.a = 0.0

func show_name(text: String) -> void:
	if name_label == null:
		push_error("BossNameUI: NameLabel puuttuu.")
		return

	name_label.text = text
	visible = true
	name_label.visible = true
	name_label.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(name_label, "modulate:a", 1.0, 0.5)

	print("BossNameUI: nimi näytetty -> ", text)

func hide_name() -> void:
	if name_label == null:
		return

	var tween = create_tween()
	tween.tween_property(name_label, "modulate:a", 0.0, 0.5)
	await tween.finished

	visible = false
	name_label.visible = false

	print("BossNameUI: nimi piilotettu")
