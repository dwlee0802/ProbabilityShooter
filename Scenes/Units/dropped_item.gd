extends Node2D
class_name DroppedItem

@onready
var button: TextureButton = $TextureButton

var item_data: ItemData

func set_data(data: ItemData) -> void:
	button = $TextureButton
	item_data = data
	#button.texture_normal = item_data.icon
	button.self_modulate = item_data.color

func _on_texture_button_pressed():
	print("button pressed")
	## if selected unit is far away, make it move over here and pick up when it arrives
	## if selected unit is close by, pick up item and queue
