# Itemin kuvauslaatikon toiminta

extends Panel

@onready var tooltip_label: Label = $TooltipLabel

func show_tooltip(text: String, pos: Vector2) -> void:
	tooltip_label.text = text
	custom_minimum_size = Vector2(160, 64)
	global_position = (pos + Vector2(16, 16)).round()
	show()

func hide_tooltip() -> void:
	hide()
