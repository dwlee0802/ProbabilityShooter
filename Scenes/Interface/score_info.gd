extends Control

var _score_component: ScoreComponent

@onready
var score_label: Label = $ScoreLabel
var displayed_score: float = 0
var displayed_score_increase: float = 500

var score_tween: Tween = null

@onready
var multiplier_label: Label = $MultiplierLabel
@onready
var multiplier_decay_bar: ProgressBar = $MultiplierLabel/MultiplierDecay

func set_score_component(component: ScoreComponent):
	_score_component = component
	_score_component.score_changed.connect(on_score_changed)
	_score_component.multiplier_changed.connect(on_multiplier_changed)
	
func on_score_changed():
	if score_tween:
		score_tween.kill()
		score_tween = null
	var new_tween: Tween = create_tween()
	score_tween = new_tween
	
	score_tween.tween_property(self, "displayed_score", _score_component.total_score, 0.2)
	
	score_label.text = "SCORE: " + str(displayed_score)

func on_multiplier_changed():
	multiplier_label.text = "BONUS: " + str(int(_score_component.get_multiplier_bonus() * 100)) + "%"
	
func _process(_delta: float) -> void:
	if !_score_component.decay_timer.is_stopped():
		multiplier_decay_bar.value = (_score_component.decay_timer.time_left / _score_component.decay_timer.wait_time) * 100.0
	else:
		multiplier_decay_bar.value = 0
		
	if score_tween != null and score_tween.is_valid():
		score_label.text = "SCORE: " + str(int(displayed_score))
