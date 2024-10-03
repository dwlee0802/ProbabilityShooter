extends Container
class_name HealthHearts

var heart_icon: PackedScene = preload("res://Scenes/Interface/health_icon.tscn")


func set_hearts_count(count: int, heart_size: Vector2 = Vector2(64,64)) -> void:
	DW_ToolBox.RemoveAllChildren(self)
	for i in range(count):
		var new_icon: TextureRect = heart_icon.instantiate()
		new_icon.custom_minimum_size = heart_size
		add_child(new_icon)

func _on_item_rect_changed() -> void:
	pivot_offset = Vector2(size.x / 2, 0)
