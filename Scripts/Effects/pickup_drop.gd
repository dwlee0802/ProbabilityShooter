extends Effect
class_name PickupDropEffect

static var ammo_pack_scene
static var health_scene
@export
var chance: float = 0
@export
var ammo_pack: bool = false
@export
var health: bool = false


static func _static_init() -> void:
	ammo_pack_scene = load("uid://cmrmaa2svvqi3")
	health_scene = load("uid://bcqi6mydg1owc")

func _init() -> void:
	var temp = PickupDropEffect.ammo_pack_scene.instantiate()
	temp.queue_free()
	temp = PickupDropEffect.health_scene.instantiate()
	temp.queue_free()
	
func activate(game_ref, _event: Event):
	if randf() > chance:
		return
	
	if ammo_pack:
		var new_ammo_pack: Pickup = PickupDropEffect.ammo_pack_scene.instantiate()
		new_ammo_pack.global_position = _event.location + DW_ToolBox.RandomVector(-100, 100)
		game_ref.add_pickup(new_ammo_pack)
	if health:
		var new_health: Pickup = PickupDropEffect.health_scene.instantiate()
		new_health.global_position = _event.location + DW_ToolBox.RandomVector(-100, 100)
		game_ref.add_pickup(new_health)
	
