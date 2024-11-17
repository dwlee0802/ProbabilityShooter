extends Control
class_name BuffIcon

var buff: Buff

@onready
var duration_shade: ColorRect = $DurationShade
@onready
var duration_label: Label = $DurationLabel


func set_buff(_buff: Buff) -> void:
	buff = _buff
	$Icon.texture = buff.buff_data.icon
	buff.finished.connect(queue_free)

func _process(_delta: float) -> void:
	if buff:
		set_shade(buff.timer.time_left / buff.timer.wait_time)
		duration_label.text = str(DW_ToolBox.TrimDecimalPoints(buff.timer.time_left, 1))
		
func set_shade(remaining_time_ratio: float) -> void:
	duration_shade.anchor_bottom = 1 - remaining_time_ratio
