extends ItemData
class_name MagnetItemData

@export
var range_increase_per_level: int = 50

func on_enter(unit: PlayerUnit, level: int):
	var shape: CircleShape2D = unit.interaction_area.get_node("CollisionShape2D").shape
	shape.radius += level * range_increase_per_level
	print("Increased interaction radius by " + str(level * range_increase_per_level))
