extends StaticBody2D
class_name Pickup
## Items that apply some effect to the player when picked up

@export
var player_unit: PlayerUnit
@export
var speed: float = 3000
@export
var arrival_distance: float = 50
var pick_up_distance: float = 200

@onready
var effect_component: PickupEffect = $Effect


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_unit:
		global_position += global_position.direction_to(player_unit.global_position) * speed * delta
		
		if global_position.distance_to(player_unit.global_position) < arrival_distance:
			on_arrived_at_player()

func on_arrived_at_player() -> void:
	effect_component.effect(player_unit)
	call_deferred("queue_free")

func on_pickup(player: PlayerUnit) -> void:
	# start flying towards player
	player_unit = player
