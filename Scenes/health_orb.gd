extends PickupEffect

@export
var heal_amount: int = 1

func effect(player: PlayerUnit) -> void:
	player.add_health(heal_amount)
