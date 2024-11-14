extends Control
class_name UpgradeUI

func clear_icons() -> void:
	for child in get_children():
		child.queue_free()
		remove_child(child)

func add_upgrade_icon(upgrade: Upgrade) -> void:
	if !upgrade:
		return
		
	var new_icon: TextureRect = TextureRect.new()
	new_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	new_icon.custom_minimum_size = Vector2(64, 64)
	if upgrade.icon:
		new_icon.texture = upgrade.icon
	else:
		new_icon.texture = upgrade.default_icon
	new_icon.tooltip_text = upgrade.description
	
	add_child(new_icon)
