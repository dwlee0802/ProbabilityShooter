extends Node
class_name StatComponent

var unit: PlayerUnit

@export
var _base_pickup_range: float = 500
var pickup_range: float = 500


func reset_stats() -> void:
	pickup_range = _base_pickup_range
	unit.set_pickup_range(pickup_range)

func add_pickup_range_bonus(amount: float) -> void:
	pickup_range += amount
	pickup_range = max(100, pickup_range)
	print("Pickup range changed. New value: " + str(pickup_range))
	unit.set_pickup_range(pickup_range)
