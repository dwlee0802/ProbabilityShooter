extends PickupEffect
class_name AmmoPack

## Ammo Pack pickup that refills the players ammo on pickup

func effect(player: PlayerUnit) -> void:
	player.weapon_one.fill_bullets()
	player.weapon_two.fill_bullets()
