extends Control

var _score_component: ScoreComponent

@onready
var score_label: Label = $ScoreLabel
@onready
var multiplier_label: Label = $MultiplierLabel
@onready
var multiplier_decay_bar: ProgressBar = $MultiplierLabel/MultiplierDecay

func set_score_component(component: ScoreComponent):
	_score_component = component
	_score_component.score_changed.connect(on_score_changed)
	_score_component.multiplier_changed.connect(on_multiplier_changed)
	
func on_score_changed():
	score_label.text = "SCORE: " + str(_score_component.total_score)

func on_multiplier_changed():
	multiplier_label.text = "BONUS: " + str(int(_score_component.get_multiplier_bonus() * 100)) + "%"
	
func _process(_delta: float) -> void:
	if !_score_component.decay_timer.is_stopped():
		multiplier_decay_bar.value = (_score_component.decay_timer.time_left / _score_component.decay_timer.wait_time) * 100.0
	else:
		multiplier_decay_bar.value = 0
