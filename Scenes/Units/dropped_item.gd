extends Interactable
class_name DroppedItem

var item_data: ItemData

@onready
var highlight: Sprite2D = $Highlight

static var selected_item: DroppedItem

func _ready():
	pass

func _physics_process(_delta: float) -> void:
	if highlight.visible:
		if DroppedItem.selected_item != self:
			set_highlight(false)
	else:
		if DroppedItem.selected_item == self:
			set_highlight(true)
		
func set_data(data: ItemData) -> void:
	item_data = data
	#button.texture_normal = item_data.icon

func active(_delta: float, _user: PlayerUnit) -> bool:
	# add item to interacting unit
	_user.add_item(item_data)
	queue_free()
	return false

func set_highlight(value: bool) -> void:
	highlight.visible = value
