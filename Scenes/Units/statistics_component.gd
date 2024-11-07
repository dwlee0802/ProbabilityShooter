extends Node
class_name StatisticsComponent

@export
var score: int = 0
@export
var survival_time: float = 0
@export
var reached_wave: int = 0

@export_category("Combat")
@export
var total_damage_output: int = 0
@export
var total_effective_damage_output: int = 0
@export
var kill_count: int = 0

@export_category("Reloading")
@export
var active_reload_success_count: int = 0
@export
var total_reload_count: int = 0

@export_category("Shooting")
@export
var bullets_fired_count: int = 0
@export
var bullets_hit_count: int = 0
@export
var critical_hit_count: int = 0

@export_category("Progression")
@export
var total_exp_gained: int = 0
@export
var level_reached: int = 1


func _process(delta: float) -> void:
	survival_time += delta * int(!get_tree().paused)

func reset_stats() -> void:
	survival_time = 0
	
	total_damage_output = 0
	total_effective_damage_output = 0
	kill_count = 0
	
	active_reload_success_count = 0
	total_reload_count = 0
	
	bullets_fired_count = 0
	bullets_hit_count = 0
	critical_hit_count = 0
	
	total_exp_gained = 0
	level_reached = 1

func export_data() -> Dictionary:
	var data_dict: Dictionary = {
		"duration": survival_time,
		"wave": reached_wave,
		"kills": kill_count,
		"timestamp": Time.get_datetime_string_from_system(),
		"level": level_reached
	}
	
	return data_dict
	
func add_exp_gained(amount: int) -> void:
	total_exp_gained += amount
	
func add_enemy_received_damage(total: int, eff: int) -> void:
	total_damage_output += total
	total_effective_damage_output += eff

func add_critical_hit_count(amount: int) -> void:
	critical_hit_count += amount

func add_bullets_fired_count(amount: int) -> void:
	bullets_fired_count += amount
	#print("Add bullets fired count " + str(amount))
	#print("Result: " + str(bullets_fired_count))
	
func add_bullets_hit_count(amount: int) -> void:
	bullets_hit_count += amount
	#print("Add bullets hit count " + str(amount))
	#print("Result: " + str(bullets_hit_count))

func add_total_reload_count(amount: int) -> void:
	total_reload_count += amount

func add_active_reload_success(amount: int) -> void:
	active_reload_success_count += amount
