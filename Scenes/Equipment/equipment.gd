extends Resource
class_name Equipment

## name of the equipment
@export
var equipment_name: String
## How long it takes to reload the action after use
@export
var reload_time: float
## How long it takes for the action to fire after use
@export
var aim_time: float

func on_activation():
	pass
