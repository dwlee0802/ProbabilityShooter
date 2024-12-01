extends CanvasLayer
class_name ShopScreen

var wave_complete_label: Label
var wave_complete_label_animation: AnimationPlayer

@onready
var shop_ui = $ShopUI


func _ready() -> void:
	wave_complete_label = $WaveCompleteLabel
	wave_complete_label_animation = wave_complete_label.get_node("AnimationPlayer")
	
func on_wave_finished() -> void:
	shop_ui.visible = false
	wave_complete_label_animation.play("wave_complete")
	await wave_complete_label_animation.animation_finished
	shop_ui.visible = true
	print("MEOWWWW")
