extends Effect
class_name PushBackEffect

@export
var strength: float = 1000

func activate(_game_ref, event: Event):
	if event.subject is PlayerUnit:
		event.subject.push_back()
