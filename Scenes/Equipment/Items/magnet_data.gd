extends UnitItemData
class_name MagnetItemData

## unit item that increases interaction range of unit

@export
var range_increase_per_level: int = 50

func on_enter(unit: PlayerUnit, level: int):
	var shape: CircleShape2D = unit.interaction_area.get_node("CollisionShape2D").shape
	shape.radius += level * range_increase_per_level
	print("Increased interaction radius by " + str(level * range_increase_per_level))

func on_exit(unit: PlayerUnit, level: int):
	var shape: CircleShape2D = unit.interaction_area.get_node("CollisionShape2D").shape
	shape.radius -= level * range_increase_per_level
	print("Increased interaction radius by " + str(level * range_increase_per_level))
