extends Orb

@export
var heal_amount: int = 1

func on_arrived_at_player() -> void:
	player_unit.add_health(heal_amount)
