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

@export_category("Stats")
## How long it takes for the action to fire after use
@export
var aim_time: float
## How long it takes to reload the action after use
@export
var reload_time: float
