extends TextureButton
class_name UpgradeOption

var data: ItemData

@onready
var name_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/NameLabel
@onready
var info_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/InfoLabel

signal option_selected(data)

func set_data(_data) -> void:
	data = _data
	name_label.text = data.item_name
	info_label.text = data.description

func _on_pressed():
	print(data.item_name + " option pressed")
	option_selected.emit(data)
