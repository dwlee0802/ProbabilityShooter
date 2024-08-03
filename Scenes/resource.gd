extends Area2D
class_name ResourceDrop

@export
var amount: int = 0

@onready
var timer: Timer = $Timer
static var resource_lifetime: float = 60.0

signal picked_up(num)


func _ready():
	timer.start(resource_lifetime)
	timer.timeout.connect(queue_free)
	
func _on_area_entered(_area):
	print("picked this up")
	picked_up.emit(amount)
	queue_free()
