extends Area2D
class_name ResourceDrop

@export
var amount: int = 0

@onready
var timer: Timer = $Timer
static var resource_lifetime: float = 60.0

var pickup_effect = preload("res://Scenes/resource_pickup_effect.tscn")

signal picked_up(num)


func _ready():
	timer.start(resource_lifetime)
	timer.timeout.connect(queue_free)
	
func _on_area_entered(_area):
	print("picked this up")
	picked_up.emit(amount)
	var new_eff = pickup_effect.instantiate()
	new_eff.global_position = global_position
	new_eff.get_node("CPUParticles2D").emitting = true
	get_tree().root.add_child(new_eff)
	queue_free()
