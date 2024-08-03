extends Control


func _on_button_pressed():
	queue_free()

func _on_kor_button_pressed():
	$TemporaryTutorial/English.visible = false
	$TemporaryTutorial/Korean.visible = true

func _on_eng_button_pressed():
	$TemporaryTutorial/English.visible = true
	$TemporaryTutorial/Korean.visible = false
