extends Node
class_name UpgradesManager

var player_unit: PlayerUnit

var upgrades = []

func connect_player_signals(player: PlayerUnit):
	pass
	
func connect_enemy_signals(enemy: EnemyUnit):
	enemy.on_death_upgrade.connect(on_enemy_killed)

func on_enemy_killed(enemy: EnemyUnit):
	for upgrade: Upgrade in upgrades:
		upgrade.on_enemy_killed(player_unit, enemy)
	
func on_enemy_hit(enemy: EnemyUnit):
	for upgrade: Upgrade in upgrades:
		upgrade.on_enemy_hit(player_unit, enemy)
		
func on_player_shoot():
	for upgrade: Upgrade in upgrades:
		upgrade.on_player_shoot(player_unit)
		
func on_player_reloaded():
	for upgrade: Upgrade in upgrades:
		upgrade.on_player_reloaded(player_unit)
