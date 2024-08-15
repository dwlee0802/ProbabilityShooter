extends Equipment
class_name Effector

## apply the effect objects onto user
func on_activation(unit: Unit, mouse_position: Vector2):
	if data is EffectorData:
		for eff: EffectObjectData in data.effects:
			unit.add_effect(eff, data.duration)
			
	super.on_activation(unit, mouse_position)
