extends Node

@export_category("Units")
@export
var unit_one: PlayerUnit
@export
var unit_two: PlayerUnit
@export
var unit_three: PlayerUnit
@export
var unit_four: PlayerUnit

@onready
var camera: CameraControl = $Camera2D


func _physics_process(delta):
	if Input.is_action_just_pressed("select_unit_one"):
		if unit_one != null:
			unit_one.selected = !unit_one.selected
	if Input.is_action_just_pressed("select_unit_two"):
		if unit_two != null:
			unit_two.selected = !unit_two.selected
	if Input.is_action_just_pressed("select_unit_three"):
		if unit_three != null:
			unit_three.selected = !unit_three.selected
	if Input.is_action_just_pressed("select_unit_four"):
		if unit_four != null:
			unit_four.selected = !unit_four.selected
		
	# center camera onto unit
	if Input.is_action_just_pressed("center_unit_one"):
		if unit_one != null:
			camera.center_camera(unit_one.position)
	if Input.is_action_just_pressed("center_unit_two"):
		if unit_two != null:
			camera.center_camera(unit_two.position)
	if Input.is_action_just_pressed("center_unit_three"):
		if unit_three != null:
			camera.center_camera(unit_three.position)
	if Input.is_action_just_pressed("center_unit_four"):
		if unit_four != null:
			camera.center_camera(unit_four.position)
