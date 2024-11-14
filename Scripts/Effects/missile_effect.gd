extends Effect
class_name MissileEffect

static var missile_scene
@export
var chance: float = 0

static func _static_init() -> void:
	missile_scene = load("res://Scenes/Units/missile.tscn")

func _init() -> void:
	var temp = MissileEffect.missile_scene.instantiate()
	temp.queue_free()
	
func activate(game_ref, _event: Event):
	if randf() > chance:
		return
		
	var new_missile: Missile = MissileEffect.missile_scene.instantiate()
	new_missile.global_position = game_ref.player_unit.global_position
	game_ref.add_missile(new_missile)
