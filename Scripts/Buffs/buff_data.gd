extends Resource
class_name BuffData

@export
var name: String = ""
@export
var icon: Texture = null
@export_multiline
var description: String = ""
## How long the buff lasts in seconds
@export
var duration: float = 0

@export_category("Stat Changes")
@export
var change_color: Color = Color.WHITE
@export
var aim_time_modifier_bonus: float = 0
