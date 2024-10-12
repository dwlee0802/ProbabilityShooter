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
@export_multiline
var description: String = ""
