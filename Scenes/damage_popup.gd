extends Node2D

func set_label(text: String) -> void:
	$Label.text = text
	$AnimationPlayer.play("damage_popup_animation")

func critical() -> void:
	$Label.add_theme_font_size_override("font_size", 120)
	$Label.add_theme_color_override("font_outline_color", Color.YELLOW)
	$AnimationPlayer.speed_scale = 1.2
