extends RefCounted
class_name Upgrade

func on_enemy_killed(player: PlayerUnit, enemy: EnemyUnit) -> void:
	# do stuff on enemy killed
	return
	
func on_enemy_hit(player: PlayerUnit, enemy: EnemyUnit) -> void:
	# do stuff on enemy hit
	return

func on_player_shoot(player_unit: PlayerUnit) -> void:
	# do stuff when player shoots
	return

func on_player_reloaded(player_unit: PlayerUnit):
	# do stuff when player reloads
	return
