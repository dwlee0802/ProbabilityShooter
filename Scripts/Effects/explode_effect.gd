extends Effect
class_name ExplodeEffect

var dynamite_scene = load("res://Scenes/Shootables/dynamite.tscn")
@export
var chance: float = 0
@export
var damage_amount: int = 1
@export
var explosion_range: float = 300

func activate(game_ref, event: Event):
	if randf() > chance:
		return
		
	var new_dynamite: Shootable = dynamite_scene.instantiate()
	new_dynamite.get_node("CollisionShape2D").disabled = true
	game_ref.call_deferred("add_child", new_dynamite)
	
	new_dynamite.global_position = event.location
	new_dynamite.radius = explosion_range
	new_dynamite.damage_amount = damage_amount
	
	new_dynamite.call_deferred("activate")
