extends CanvasLayer
class_name UserInterface

@onready
var reload_label: Label = $UnitState/ReloadLabel


func update_reload_label(time: float) -> void:
	reload_label.text = "Reloading: " + str(int(time * 100)/100.0)
