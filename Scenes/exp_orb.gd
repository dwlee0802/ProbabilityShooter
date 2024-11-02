extends StaticBody2D
class_name Orb

@export
var player_unit: PlayerUnit
@export
var speed: float = 3000
@export
var exp_amount: int = 100
@export
var arrival_distance: float = 50
var pick_up_distance: float = 200

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_unit:
		global_position += global_position.direction_to(player_unit.global_position) * speed * delta
		
		if global_position.distance_to(player_unit.global_position) < arrival_distance:
			on_arrived_at_player()

func on_arrived_at_player() -> void:
	player_unit.exp_orb_effect()
	player_unit.add_experience(exp_amount)
	call_deferred("queue_free")

func on_pickup(player: PlayerUnit) -> void:
	# start flying towards player
	player_unit = player
