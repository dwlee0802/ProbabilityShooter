extends Interactable

@export
var core: Core

@export
var consumption_speed: float = 1
var time_holder: float = 0

@onready
var interaction_label: Label = $InteractionLabel


# called every frame by the interactor
# returns false if process is finished
func active(_delta: float, _user: PlayerUnit) -> bool:
	core.active = true
	
	if core.game_ref.resource_stock <= 0:
		core.active = false
		return false
		
	## increase core activation process if resources are available
	time_holder += _delta
	var progress: float = time_holder / consumption_speed * 100
	progress = min(progress, 100)
	core.progress_radial_progress.progress = progress
	if time_holder >= consumption_speed:
		# consume resource
		core.game_ref.change_resource(-1)
		
		time_holder = 0
		return !core.increase_activation(1)
	
	return true

func _on_area_2d_area_entered(_area):
	interaction_label.visible = true
	if core.game_ref.resource_stock <= 0:
		interaction_label.text = "Not enough resources"
	else:
		interaction_label.text = "E"

func _on_area_2d_area_exited(_area):
	interaction_label.visible = false
