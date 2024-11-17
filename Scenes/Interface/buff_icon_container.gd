extends HFlowContainer
class_name BuffIconContainer

static var buff_icon_scene: PackedScene


static func _static_init() -> void:
	buff_icon_scene = load("res://Scenes/Interface/buff_icon.tscn")

func _ready() -> void:
	clear_buff_icons()
	
func add_buff_icon(buff: Buff) -> void:
	var new_icon: BuffIcon = buff_icon_scene.instantiate()
	new_icon.set_buff(buff)
	add_child(new_icon)

func clear_buff_icons() -> void:
	DW_ToolBox.RemoveAllChildren(self)
