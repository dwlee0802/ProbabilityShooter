extends HBoxContainer
class_name HealthHearts

var heart_icon: PackedScene = preload("res://Scenes/Interface/health_icon.tscn")


func _ready() -> void:
	set_hearts_count(5)
	
func set_hearts_count(count: int) -> void:
	DW_ToolBox.RemoveAllChildren(self)
	for i in range(count):
		var new_icon: TextureRect = heart_icon.instantiate()
		add_child(new_icon)
