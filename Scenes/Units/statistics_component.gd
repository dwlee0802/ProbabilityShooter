extends Node
class_name StatisticsComponent

@export
var survival_time: float = 0

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
var level: int = 1


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
	level = 1
	