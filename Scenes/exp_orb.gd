extends Sprite2D
class_name Orb

@export
var player_unit: PlayerUnit
@export
var speed: float = 3000
@export
var exp_amount: int = 100
@export
var arrival_distance: float = 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += global_position.direction_to(player_unit.global_position) * speed * delta
	if global_position.distance_to(player_unit.global_position) < arrival_distance:
		on_arrived_at_player()
		queue_free()

func on_arrived_at_player() -> void:
	player_unit.add_experience(exp_amount)
