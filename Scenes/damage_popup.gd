extends Node2D

func set_label(text: String) -> void:
	$Label.text = text
	$AnimationPlayer.play("damage_popup_animation")
