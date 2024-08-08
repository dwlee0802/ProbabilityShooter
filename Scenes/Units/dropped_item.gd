extends Interactable
class_name DroppedItem

@onready
var button: TextureButton = $TextureButton

var item_data: ItemData

func set_data(data: ItemData) -> void:
	button = $TextureButton
	item_data = data
	#button.texture_normal = item_data.icon
	button.self_modulate = item_data.color

func active(_delta: float, _user: PlayerUnit) -> bool:
	# add item to interacting unit
	_user.add_item(item_data)
	queue_free()
	return false
