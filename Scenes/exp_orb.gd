extends PickupEffect

@export
var exp_amount: int = 100

func effect(player: PlayerUnit) -> void:
	player.exp_orb_effect()
	player.add_experience(exp_amount)
