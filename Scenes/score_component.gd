extends Node
class_name ScoreComponent

@export
var total_score: int = 0
@export
var kill_score_amount: int = 100

@export_category("Multiplier")
@export
var multiplier_level: int = 0
@export
var multiplier_per_level: float = 0.25
@export
var multiplier_decay_time: float = 1
var decay_timer: Timer

signal score_changed
signal multiplier_changed


func _ready() -> void:
	decay_timer = Timer.new()
	add_child(decay_timer)
	decay_timer.autostart = false
	decay_timer.one_shot = false
	decay_timer.timeout.connect(on_decay_timeout)
	
# add score and return added amount
func on_kill() -> int:
	# add score
	var amount: int = int(kill_score_amount * (1.0 + get_multiplier_bonus()))
	total_score += amount
	score_changed.emit()
	
	# increase multiplier
	multiplier_level += 1
	multiplier_changed.emit()
	
	# reset multiplier decay timer
	reset_decay()
	
	return amount

func get_multiplier_bonus() -> float:
	return multiplier_level * multiplier_per_level

func on_decay_timeout() -> void:
	multiplier_level = 0
	multiplier_changed.emit()
	if multiplier_level == 0:
		decay_timer.stop()

func reset_decay() -> void:
	decay_timer.stop()
	decay_timer.start(multiplier_decay_time)
	
func reset() -> void:
	multiplier_level = 0
	multiplier_changed.emit()
	total_score = 0
	score_changed.emit()
