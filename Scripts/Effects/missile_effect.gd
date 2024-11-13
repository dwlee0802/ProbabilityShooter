extends Effect
class_name MissileEffect

var missile_scene = preload("res://Scenes/Units/missile.tscn")
@export
var chance: float = 0

func activate(game_ref, _event: Event):
	if randf() > chance:
		return
		
	var new_missile: Missile = missile_scene.instantiate()
	new_missile.global_position = game_ref.player_unit.global_position
	game_ref.add_missile(new_missile)
