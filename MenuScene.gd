extends Node2D

func _unhandled_input(event):
	if event.is_action_pressed("player_action1"):
		queue_free()
		var game_game = preload("res://GameMain.tscn").instance()
		get_parent().add_child(game_game)
