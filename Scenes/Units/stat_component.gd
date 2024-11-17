extends Node
class_name StatComponent

var unit: PlayerUnit

@export
var _base_pickup_range: float = 500
var pickup_range: float = 500

@export
var _base_reload_time_modifier: float = 1
var reload_time_modifier: float = 1
const reload_time_modifier_min = 0.25
const reload_time_modifier_max = 4

@export
var _base_aim_time_modifier: float = 1
var aim_time_modifier: float = 1
const aim_time_modifier_min = 0.2
const aim_time_modifier_max = 3

@export
var _base_projectile_speed_modifier: float = 1
var projectile_speed_modifier: float = 1
const projectile_speed_modifier_min = 0.5
const projectile_speed_modifier_max = 10


func reset_stats() -> void:
	reload_time_modifier = _base_reload_time_modifier
	aim_time_modifier = _base_aim_time_modifier
	pickup_range = _base_pickup_range
	unit.set_pickup_range(pickup_range)
	projectile_speed_modifier = _base_projectile_speed_modifier

func add_pickup_range_bonus(amount: float) -> void:
	pickup_range += amount
	pickup_range = max(100, pickup_range)
	print("Pickup range changed. New value: " + str(pickup_range))
	unit.set_pickup_range(pickup_range)

func add_reload_time_modifier(amount: float) -> void:
	reload_time_modifier += amount
	# limit reload time modifier
	if reload_time_modifier < reload_time_modifier_min:
		reload_time_modifier = reload_time_modifier_min
	if reload_time_modifier > reload_time_modifier_max:
		reload_time_modifier = reload_time_modifier_max
		
func add_aim_time_modifier(amount: float) -> void:
	aim_time_modifier += amount
	# limit aim time modifier
	if aim_time_modifier < aim_time_modifier_min:
		aim_time_modifier = aim_time_modifier_min
	if aim_time_modifier > aim_time_modifier_max:
		aim_time_modifier = aim_time_modifier_max

func add_projectile_speed_modifier(amount: float) -> void:
	projectile_speed_modifier += amount
	# limit proj speed modifier
	if projectile_speed_modifier < projectile_speed_modifier_min:
		projectile_speed_modifier = projectile_speed_modifier_min
	if projectile_speed_modifier > projectile_speed_modifier_max:
		projectile_speed_modifier = projectile_speed_modifier_max
