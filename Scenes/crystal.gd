extends Node2D
class_name Crystal

@export
var player_unit: PlayerUnit

@onready
var animation: AnimationPlayer = $Polygon2D/AnimationPlayer

signal picked_up

func pick_up():
	picked_up.emit()
	print("picked up crystal")
	animation.play("consume")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerUnit:
		pick_up()
