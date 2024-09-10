extends Node
class_name ActiveReloadComponent

func update_reload_marker(node: Node2D = get_parent()):
	var marker: RadialProgress = node.get_node("Control/ActiveReloadMarker")
	var unit: PlayerUnit = InputManager.selected_unit
	if unit == null:
		return
	var mid_point: float = (unit.active_reload_range.x + unit.active_reload_range.y)/2.0
	#print("mid point: " + str(mid_point))
	var angle: float = mid_point/100.0 * 360
	marker.rotation_degrees = angle - (marker.progress / 2.0) / 100 * 360
	#print("angle: " + str(marker.rotation))
