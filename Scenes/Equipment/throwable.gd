extends Consumable
class_name Throwable

## consumables disappear after use
func on_activation(_unit: Unit, _direction: Vector2):
	# make projectile and send it to direction
	
	super.on_activation(_unit, _direction)
