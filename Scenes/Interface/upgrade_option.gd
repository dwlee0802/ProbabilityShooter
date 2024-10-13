extends TextureButton
class_name UpgradeOption

var data: Upgrade

@onready
var name_label: Label = $MarginContainer/VContainer/NameLabel
@onready
var info_label: RichTextLabel = $MarginContainer/VContainer/InfoLabel

signal option_selected(data)

func set_data(_data) -> void:
	if _data == null:
		push_error("Upgrade option data null")
		return
		
	$PressedShade.visible = false
	data = _data
	name_label.text = data.upgrade_name
	info_label.text = data.description
	if data.icon != null:
		$MarginContainer/VContainer/Icon.texture = _data.icon
	else:
		$MarginContainer/VContainer/Icon.texture = _data.default_icon

func _on_mouse_entered() -> void:
	$HoverShade.visible = true

func _on_mouse_exited() -> void:
	$HoverShade.visible = false

func _on_toggled(toggled_on: bool) -> void:
	$PressedShade.visible = toggled_on
