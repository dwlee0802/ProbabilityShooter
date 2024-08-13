extends Equipment
class_name Consumable

## consumables disappear after use
func on_activation(_unit: Unit, _direction: Vector2):
	## do something
	
	## remove self
	## equip main weapon
	_unit.set_current_equipment(0)
	_unit.remove_equipment(1)
	return
