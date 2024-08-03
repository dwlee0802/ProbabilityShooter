extends Interactable

@export
var core: Core

@export
var resource_consumption_per_second: float = 1
var progress_per_resource: float = 0.1
var time_holder: float = 0

# called every frame by the interactor
# returns false if process is finished
func active(_delta: float, _user: PlayerUnit) -> bool:
	## increase core activation process if resources are available
	time_holder += _delta
	if time_holder >= 1:
		# consume resource
		
		time_holder = 0
		return !core.increase_activation(progress_per_resource)
	
	return true
