extends CanvasLayer
class_name UserInterface

var reload_label: Label


func _ready():
	reload_label = $ReloadLabel

func update_reload_label(time: float) -> void:
	reload_label.text = " Reloading: " + str(int(time * 100)/100.0)
