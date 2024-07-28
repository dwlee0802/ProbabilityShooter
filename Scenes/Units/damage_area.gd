extends EffectArea
class_name DamageArea

@export
var damage_per_second: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	super._physics_process(delta)
	# enemy units
	for unit in bodies:
		unit.receive_hit(damage_per_second * delta)
	# player units
	for unit in areas:
		unit.receive_hit(damage_per_second * delta)
