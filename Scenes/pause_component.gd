extends Node

var game_ref: Game

var paused: bool = false


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause_game"):
		if !paused:
			game_ref.game_paused_screen.visible = true
			get_tree().paused = true
			paused = true
		else:
			game_ref.game_paused_screen.visible = false
			get_tree().paused = false
			paused = false

func unpause() -> void:
	game_ref.game_paused_screen.visible = false
	get_tree().paused = false
	paused = false
