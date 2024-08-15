extends Resource
class_name EquipmentData

@export_category("Info")
## name of the equipment
@export
var equipment_name: String
## ui image of equipment
@export
var equipment_texture: Texture2D
## actual in-game image
@export
var equipment_sprite: Texture2D
@export
var equipment_use_sound: Resource
@export
var reload_sound: Resource
## If true, this equipment is deleted after one time use
@export
var is_consumable: bool = false
