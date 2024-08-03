extends Interactable

@export
var core: Core

# called every frame by the interactor
# returns false if process is finished
func active(_delta: float, _user: PlayerUnit) -> bool:
	## increase core activation process if resources are available
	return !core.increase_activation(_delta * 10)
	
