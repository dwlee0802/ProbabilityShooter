extends Interactable

static var heal_per_second: float = 10

# called every frame by the interactor
# returns false if process is finished
func active(_delta: float, user: PlayerUnit) -> bool:
	user.add_health(heal_per_second * _delta)
	if user.health_points == user.max_health_points:
		print("Healing complete.")
		return false
		
	return true
