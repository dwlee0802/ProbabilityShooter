extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	queue_free()


func _on_kor_button_pressed():
	$TemporaryTutorial/English.visible = false
	$TemporaryTutorial/Korean.visible = true


func _on_eng_button_pressed():
	$TemporaryTutorial/English.visible = true
	$TemporaryTutorial/Korean.visible = false
