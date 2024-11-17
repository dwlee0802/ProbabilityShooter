extends Effect
class_name AddTraitEffect

@export_category("Enable Bullet Traits")
@export
var piercing_chance_bonus: float = 0
@export
var explosive_chance_bonus: float = 0
@export
var quickshot_chance_bonus: float = 0
@export
var fire_chance_bonus: float = 0
@export
var vampire_chance_bonus: float = 0


func activate(_game_ref: Game, event: Event):
	if event.subject is PlayerUnit:
		var bullet_generator: BulletGenerator = event.subject.bullet_generator_component
		bullet_generator.apply_upgrade(self)
		event.subject.stats_changed.emit()
		print("meow?")
