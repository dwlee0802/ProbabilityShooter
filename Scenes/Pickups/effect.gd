extends PickupEffect

func effect(_player: PlayerUnit) -> void:
	_player.add_health(1)
