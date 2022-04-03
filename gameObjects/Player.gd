extends KinematicBody2D


const FRICTION: float = .3
const MAX_JUMP_FORCE: float = 175.0
const JUMP_LERP_SPEED: float = 1199.0
const MAX_FALL_SPEED: float = 370.0
const MAX_MOVE_SPEED: float = 139.0
const ACCERLATION: float = 3000.0
const GRAVITY: float = 1050.0

var jump_force: float
var motion: Vector2

var jumps_left: int

var softballs: Array = []
var cur_ball


func _ready() -> void:
	motion = Vector2.ZERO
	jump_force = MAX_JUMP_FORCE
	jumps_left = 2


func _physics_process(delta: float) -> void:
	if not InGame.game_over:
		_apply_movement(delta)
		_apply_jump(delta)
	_apply_gravity(delta)
	
	if Input.get_action_strength("player_action1") and not InGame.game_over:
		_hooking_ball(delta)
	motion = move_and_slide(motion, Vector2.UP)


func _hooking_ball(delta: float) -> void:
	if cur_ball:
		var ball_dist: float = $HookPos.global_position.distance_to(cur_ball.position)
		var the_sprite: Sprite = $HookPos/LinkSprite
		the_sprite.region_rect = Rect2(0, 0, 8, ball_dist)
		var tar_vec: Vector2 = cur_ball.position
		tar_vec = (position+$HookPos.position) - tar_vec
		the_sprite.rotation_degrees = rad2deg(($HookPos.global_position).angle_to_point(cur_ball.position))+90
		
		tar_vec = tar_vec.normalized()*1005
		cur_ball.vel += tar_vec*delta


func _apply_jump(delta: float) -> void:
	if jump_force > 0:
		if Input.get_action_strength("player_jump"):
			jump_force -= JUMP_LERP_SPEED*delta
			if jump_force <= 0:
				jump_force = 0
			motion.y += -jump_force
			return
		jump_force = 0
		return
	if is_on_floor() and Input.is_action_just_pressed("player_jump"):
		jump_force = MAX_JUMP_FORCE
		motion.y += -jump_force
		$JumpSound.play()


func _apply_movement(delta: float) -> void:
	var x_input: int = int(Input.get_action_strength("ui_right")) - int(Input.get_action_strength("ui_left"))
	
	if x_input == 0:
		motion.x = lerp(motion.x, 0, FRICTION)
		return
	motion.x += ACCERLATION*x_input*delta
	motion.x = clamp(motion.x, -MAX_MOVE_SPEED, MAX_MOVE_SPEED)


func _apply_gravity(delta: float) -> void:
	motion.y += GRAVITY * delta
	if motion.y >= MAX_FALL_SPEED:
		motion.y = MAX_FALL_SPEED


func _unhandled_input(event):
	if event.is_action_pressed("player_action1") and not InGame.game_over:
		if softballs.size() > 0:
			var cur_dist: float
			for i in softballs:
				if cur_dist:
					if $HookPos.global_position.distance_to(i.position) < cur_dist:
						cur_dist = $HookPos.global_position.distance_to(i.position)
						cur_ball = i
					continue
				cur_dist = $HookPos.global_position.distance_to(i.position)
				cur_ball = i
			if cur_ball:
				cur_ball.grabbed = true
				$HookPos/LinkSprite.visible = true
			$LatchSound.play()
	elif event.is_action_released("player_action1") and not InGame.game_over:
		if cur_ball:
			softballs.remove(softballs.find(cur_ball))
			cur_ball.released = true
			cur_ball = null
			$HookPos/LinkSprite.visible = false


func _on_GrabArea_area_entered(area: Area2D):
	if area.is_in_group("softball"):
		if not area.grabbed:
			softballs.append(area)


func _on_GrabArea_area_exited(area):
	if area.is_in_group("softball"):
		if not area.grabbed:
			softballs.remove(softballs.find(area))
