extends Effect
class_name PushBackEffect

func activate(_game_ref, event: Event):
	if event.subject is PlayerUnit:
		event.subject.push_back()
