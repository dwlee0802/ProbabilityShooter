extends Effect
class_name PlayerStatEffect

@export
var speed_bonus: float = 0


func activate(_game_ref, _event: Event):
	print("stat change")
	if _event.subject is PlayerUnit:
		_event.subject.add_movement_bonus(speed_bonus)
