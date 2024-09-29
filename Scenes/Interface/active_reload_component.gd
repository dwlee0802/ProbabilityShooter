extends Node
class_name ActiveReloadComponent

func update_reload_marker(node, weapon: WeaponComponent):
	var marker: Control = node.get_node("TextureRect")
	var sub_marker: Control = marker.get_node("TextureRect2")
	var mid_point: float = (weapon.active_reload_range.x + weapon.active_reload_range.y)/2.0
	# set marker position
	marker.size.y = weapon.active_reload_length
	sub_marker.size.y = weapon.active_reload_rim_length
	marker.position.y = 100 - mid_point - weapon.active_reload_length / 2.0
	sub_marker.position.y = -weapon.active_reload_rim_length
