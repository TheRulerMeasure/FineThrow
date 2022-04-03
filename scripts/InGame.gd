extends Node


var scores: int

var game_over: bool


func _ready():
	scores = 0
	game_over = false

func add_score(a: int) -> void:
	scores += a
