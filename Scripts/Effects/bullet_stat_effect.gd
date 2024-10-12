extends Effect
class_name BulletStatEffect

@export
var damage_change: int = 0
@export
var piercing_change: int = 0

func activate(_game_ref, event: Event):
	if event.subject is Projectile:
		event.subject.pierce_count += piercing_change
		event.subject.damage_amount += damage_change
