extends EffectArea
class_name SlowArea

@export
var slow_amount: float = 0
@export
var slow_ratio: float = 0

func _on_body_entered(body):
	if body is EnemyUnit:
		body.movement_speed_modifier += -slow_amount
		body.movement_speed_multiplier += -slow_ratio

func _on_body_exited(body):
	if body is EnemyUnit:
		body.movement_speed_modifier -= -slow_amount
		body.movement_speed_multiplier -= -slow_ratio

func _on_area_entered(area):
	if area is PlayerUnit:
		area.movement_speed_modifier += -slow_amount
		area.movement_speed_multiplier += -slow_ratio

func _on_area_exited(area):
	if area is PlayerUnit:
		area.movement_speed_modifier -= -slow_amount
		area.movement_speed_multiplier -= -slow_ratio
