extends Node
class_name ScoreComponent

@export
var total_score: int = 0
@export
var kill_score_amount: int = 100

@export_category("Multiplier")
@export
var multiplier_bonus: float = 0
@export
var bonus_per_kill: float = 20
@export
var multiplier_decay_time: float = 1
var decay_timer: Timer

signal score_changed


func _ready() -> void:
	decay_timer = Timer.new()
	add_child(decay_timer)
	decay_timer.autostart = true
	decay_timer.one_shot = false
	decay_timer.timeout.connect(on_decay_timeout)

func _process(delta: float) -> void:
	if multiplier_bonus > 0:
		multiplier_bonus -= delta
	else:
		multiplier_bonus = 0
		
# add score and return added amount
func on_kill() -> int:
	# add score
	var amount: int = int(kill_score_amount * (1.0 + get_multiplier_bonus()))
	total_score += amount
	score_changed.emit()
	
	# increase multiplier
	multiplier_bonus += bonus_per_kill
	
	# reset multiplier decay timer
	reset_decay()
	
	return amount

func get_multiplier_bonus() -> float:
	return int(multiplier_bonus) * 0.01

func reset_decay() -> void:
	decay_timer.stop()
	decay_timer.start(multiplier_decay_time)
	
func reset() -> void:
	multiplier_bonus = 0
	total_score = 0
	score_changed.emit()
