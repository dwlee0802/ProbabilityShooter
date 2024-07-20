extends CanvasLayer
class_name UserInterface

var reload_labels = []


func _ready():
	reload_labels = $ReloadState.get_children()

## reload the reload labels texts
func update_reload_labels(times) -> void:
	for i: int in range(reload_labels.size()):
		reload_labels[i].visible = i < times.size()
		if reload_labels[i].visible:
			if times[i] == 0:
				reload_labels[i].text = "READY"
			else:
				reload_labels[i].text = "Reloading(" + str(int(times[i] * 100)/100.0) + ")"
