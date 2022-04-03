extends KinematicBody2D


const SOFTBALL = preload("res://gameObjects/SoftBall.tscn")

export var player_mode_path: NodePath
export var score_label_path: NodePath
export var game_over_label_path: NodePath
export(float, 0.1, 10, 0.02) var min_delay
export(float, 0.1, 10, 0.02) var max_delay
export var launch_speed: float = 350

var player_node
var motion: Vector2
var spawn_delay: float
var back_force: float

var rand = RandomNumberGenerator.new()


func _ready() -> void:
	rand.randomize()
	back_force = 0
	player_node = get_node(player_mode_path)
	spawn_delay = rand_range(min_delay, max_delay)
	motion = Vector2(-12.0, 0.0)
	_set_face_pos()


func _process(delta: float) -> void:
	spawn_delay -= delta
	if spawn_delay <= 0:
		_throw_pie()
		spawn_delay = rand.randf_range(min_delay, max_delay)


func _physics_process(delta: float) -> void:
	back_force -= 50*delta
	if back_force <= 0:
		back_force = 0
	
	if back_force > 0:
		motion.x = back_force
	else:
		motion.x = -12.0
	move_and_slide(motion)


func push_back(a: float):
	back_force += a


func _set_face_pos() -> void:
	$FaceArea.position.y = rand.randf_range(-300, -10)


func _throw_pie() -> void:
	var my_ball = SOFTBALL.instance()
	get_parent().add_child(my_ball)
	my_ball.position = Vector2(position.x, rand.randf_range(0, 400))
	
	var tar_vec: Vector2 = player_node.position - my_ball.position
	tar_vec = tar_vec.normalized()*launch_speed
	my_ball.vel = tar_vec


func _on_FaceArea_area_entered(area):
	if area.is_in_group("softball"):
		if area.released:
			var score_label: Label = get_node(score_label_path)
			InGame.add_score(1)
			score_label.text = "Scores: " + str(InGame.scores)
			push_back(50)
			_set_face_pos()
			player_node.softballs.remove(player_node.softballs.find(player_node.cur_ball))
#			player_node.cur_ball = null
			area.queue_free()
			$ScoreSound.play()


func _on_GameOverArea_body_entered(body: KinematicBody2D) -> void:
	if body.is_in_group("player"):
		var game_over_label: Label = get_node(game_over_label_path)
		InGame.game_over = true
		game_over_label.text = "Game Over"
