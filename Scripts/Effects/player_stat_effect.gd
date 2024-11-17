extends Effect
class_name PlayerStatEffect

@export
var speed_bonus: float = 0
@export
var pickup_range_bonus: float = 0
@export
var projectile_speed_modifier_bonus: float = 0

func activate(_game_ref, _event: Event):
	print("stat change")
	if _event.subject is PlayerUnit:
		var player: PlayerUnit = _event.subject
		player.add_movement_bonus(speed_bonus)
		player.stat_component.add_pickup_range_bonus(pickup_range_bonus)
		player.stat_component.add_projectile_speed_modifier(projectile_speed_modifier_bonus)
