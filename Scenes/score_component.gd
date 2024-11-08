extends Node
class_name ScoreComponent

@export
var total_score: int = 0
	
@export
var kill_score_amount: int = 100
var highscore: int = 0

@export_category("Multiplier")
@export
var multiplier_bonus: float = 0
@export
var bonus_per_kill: float = 50
@export
var multiplier_decay_time: float = 10
var score_tween: Tween = null

signal score_changed


func _ready() -> void:
	pass
		
# add score and return added amount
func on_kill() -> int:
	# add score
	var amount: int = int(kill_score_amount * (1.0 + get_multiplier_bonus()))
	total_score += amount
	if total_score > highscore:
		highscore = total_score
	score_changed.emit()
	
	# increase multiplier
	multiplier_bonus += bonus_per_kill
	
	# reset multiplier decay timer
	reset_decay()
	
	return amount

func get_multiplier_bonus() -> float:
	return int(multiplier_bonus) * 0.01

func reset_decay() -> void:
	if score_tween:
		score_tween.kill()
		score_tween = null
	var new_tween: Tween = create_tween()
	score_tween = new_tween
	
	score_tween.tween_property(self, "multiplier_bonus", 0, multiplier_decay_time)
	
func reset() -> void:
	multiplier_bonus = 0
	if score_tween:
		score_tween.kill()
		score_tween = null
	total_score = 0
	score_changed.emit(true)
