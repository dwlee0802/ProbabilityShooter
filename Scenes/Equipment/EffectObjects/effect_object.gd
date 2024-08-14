extends Resource
class_name EffectObject

@export
var duration: float = 0

func effect(unit: PlayerUnit) -> void:
	print("do something to unit")
