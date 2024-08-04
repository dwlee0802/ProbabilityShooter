extends Item
class_name MagnetItem

func on_enter(unit: PlayerUnit):
	var shape: CircleShape2D = unit.interaction_area.get_node("CollisionShape2D").shape
	shape.radius += level * data.range_increase_per_level
	print("Increased radius by " + str(level * data.range_increase_per_level))
