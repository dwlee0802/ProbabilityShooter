extends EffectArea
class_name SlowArea

@export
var slow_amount: float = 0


func _on_body_entered(body):
	if body is EnemyUnit:
		body.movement_speed_modifier += -slow_amount

func _on_body_exited(body):
	if body is EnemyUnit:
		body.movement_speed_modifier -= -slow_amount

func _on_area_entered(area):
	if area is PlayerUnit:
		area.movement_speed_modifier += -slow_amount

func _on_area_exited(area):
	if area is PlayerUnit:
		area.movement_speed_modifier -= -slow_amount
