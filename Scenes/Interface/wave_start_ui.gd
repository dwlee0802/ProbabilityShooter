extends MarginContainer
class_name WaveStartUI

@onready
var animation: AnimationPlayer = $StartingLabel/AnimationPlayer
@onready
var label: Label = $StartingLabel

func wave_start(wave: int) -> void:
	label.text = "WAVE " + str(wave)
	animation.play("wave_start")
