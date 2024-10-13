extends Resource
class_name Upgrade

@export
var condition_event_code: Event.EventCode
@export
var effect: Effect = null

@export_category("Base Info")
@export
var upgrade_name: String = ""
@export
var icon: Texture
static var default_icon: Texture
@export
var color: Color = Color.WHITE

@export_multiline
var description: String = ""
@export
var disabled: bool = true

static func _static_init() -> void:
	default_icon = load("res://Art/32x32_white_square.png")
	
func _to_string() -> String:
	return upgrade_name
