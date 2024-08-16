extends TextureButton
class_name UpgradeOption

var data: ItemData

@onready
var name_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/NameLabel
@onready
var info_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/InfoLabel

signal option_selected(data)

func set_data(_data) -> void:
	$PressedShade.visible = false
	data = _data
	name_label.text = data.item_name
	info_label.text = data.description

func _on_pressed():
	$PressedShade.visible = true
	if data != null:
		print(data.item_name + " option pressed")
	option_selected.emit(data)

func _on_mouse_entered() -> void:
	$HoverShade.visible = true

func _on_mouse_exited() -> void:
	$HoverShade.visible = false
