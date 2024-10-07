extends Interactable
class_name DroppedItem

@export
var item_data: ItemData

@onready
var item_sprite: Sprite2D = $Icon/ItemSprite
@onready
var highlight: Sprite2D = $Icon/Highlight

# static variable to hold current selected item
static var selected_item: DroppedItem = null


func _ready():
	set_data(item_data)

func _physics_process(_delta: float) -> void:
	# turn on and off highlight
	if highlight.visible:
		if DroppedItem.selected_item != self:
			set_highlight(false)
	else:
		if DroppedItem.selected_item == self:
			set_highlight(true)
		
func set_data(data: ItemData) -> void:
	item_data = data
	if data.icon == null:
		$Icon/ItemSprite.texture = data.default_icon
		$Icon/ItemSprite.self_modulate = data.color
	else:
		$Icon/ItemSprite.texture = data.icon
		$Icon/ItemSprite.self_modulate = Color.WHITE

# one time interaction
func use(user) -> void:
	user.add_to_inventory(item_data)
	$CollisionShape2D.disabled = true
	$Icon/AnimationPlayer.play("consume")
	
func active(_delta: float, _user) -> bool:
	return false
	
func set_highlight(value: bool) -> void:
	highlight.visible = value
