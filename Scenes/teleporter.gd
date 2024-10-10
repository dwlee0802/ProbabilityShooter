extends Interactable
class_name Teleporter

var current_crystals_count: int = 0
var crystals_needed: int = 3

func add_crystal_count(count: int) -> void:
	current_crystals_count += count
