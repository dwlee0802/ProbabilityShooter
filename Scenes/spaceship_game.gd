extends Node2D

@onready
var ship_info_label: Label = $CanvasLayer/ShipInfoLabel
@onready
var player_spaceship : Spaceship = $Spaceship

var enemy_scene: PackedScene = preload("res://Scenes/Units/enemy_unit.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	ship_info_label.text = ""
	ship_info_label.text += "LINEAR SPD: " + str(player_spaceship.linear_velocity.length()) + "\n"
	ship_info_label.text += "ANGULAR SPD: " + str(player_spaceship.angular_velocity)
