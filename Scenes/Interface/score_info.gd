extends Control

var _score_component: ScoreComponent

@onready
var score_label: Label = $ScoreLabel
var displayed_score: float = 0
var displayed_score_increase: float = 500
var score_tween: Tween = null

@onready
var highscore_label: Label = $HighscoreLabel
var displayed_highscore: float = 0
var highscore_tween: Tween = null

@onready
var multiplier_label: Label = $MultiplierLabel
@onready
var multiplier_decay_bar: ProgressBar = $MultiplierLabel/MultiplierDecay


func set_score_component(component: ScoreComponent):
	_score_component = component
	_score_component.score_changed.connect(on_score_changed)
	displayed_highscore = component.highscore
	highscore_label.text = "HIGHSCORE: " + str(component.highscore)
	
func on_score_changed(immediate: bool = false):
	if immediate:
		score_label.text = "SCORE: " + str(_score_component.total_score)
		highscore_label.text = "HIGHSCORE: " + str(_score_component.highscore)
		return
		
	if score_tween:
		score_tween.kill()
		score_tween = null
	var new_tween: Tween = create_tween()
	score_tween = new_tween
	
	score_tween.set_parallel(true)
	score_tween.tween_property(self, "displayed_score", _score_component.total_score, 0.2)
	score_tween.tween_property(self, "displayed_highscore", _score_component.highscore, 0.2)

func on_multiplier_changed():
	multiplier_label.text = "BONUS: " + str(int(_score_component.get_multiplier_bonus() * 100)) + "%"
	
func _process(_delta: float) -> void:
	var tw: Tween = _score_component.score_tween
	if tw != null and tw.is_valid():
		multiplier_label.text = "BONUS: " + str(int(_score_component.get_multiplier_bonus() * 100)) + "%"
		multiplier_decay_bar.value = (_score_component.multiplier_decay_time - tw.get_total_elapsed_time())/_score_component.multiplier_decay_time * 100
	else:
		multiplier_label.text = "BONUS: 0%"
		multiplier_decay_bar.value = 0
		
	if score_tween != null and score_tween.is_valid():
		score_label.text = "SCORE: " + str(int(displayed_score))
	if score_tween != null and score_tween.is_valid():
		highscore_label.text = "HIGHSCORE: " + str(int(displayed_highscore))
		
