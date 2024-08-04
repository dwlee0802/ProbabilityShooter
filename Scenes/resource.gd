extends Area2D
class_name ResourceDrop

@export
var amount: int = 0

@onready
var timer: Timer = $Timer
static var resource_lifetime: float = 60
var half_life_passed: bool = false

var pickup_effect = preload("res://Scenes/resource_pickup_effect.tscn")

signal picked_up(num)


func _ready():
	timer.start(resource_lifetime)
	timer.timeout.connect(queue_free)

func _process(_delta):
	if !half_life_passed and timer.time_left / resource_lifetime < 0.5:
		$CPUParticles2D.amount = 20
		$CPUParticles2D.scale_amount_max = 0.1
		half_life_passed = true
		
func _on_area_entered(_area):
	print("picked this up")
	picked_up.emit(amount)
	var new_eff = pickup_effect.instantiate()
	new_eff.global_position = global_position
	new_eff.get_node("CPUParticles2D").emitting = true
	get_tree().root.add_child(new_eff)
	queue_free()

func _on_mouse_entered():
	_on_area_entered(null)
