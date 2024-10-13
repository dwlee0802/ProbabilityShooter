extends Effect
class_name AddTraitEffect

@export_category("Enable Bullet Traits")
@export
var piercing: bool = false
@export
var explosive: bool = false
@export
var buckshot: bool = false
@export
var quickshot: bool = false
@export
var fire: bool = false
@export
var double_damage: bool = false
@export
var vampire: bool = false

func activate(_game_ref: Game, event: Event):
	if event.subject is PlayerUnit:
		var bullet_generator: BulletGenerator = event.subject.bullet_generator_component
		bullet_generator.apply_upgrade(self)
		event.subject.stats_changed.emit()
		print("meow?")
