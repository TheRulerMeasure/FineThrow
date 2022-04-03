extends Area2D


export var vel: Vector2
export var grabbed: bool = false
export var released: bool = false

var should_be_removed: bool = false


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if should_be_removed:
		if not grabbed:
			queue_free()
	if position.x < 0:
		should_be_removed = true
	elif position.x > 640:
		should_be_removed = true
	elif position.y < 0:
		should_be_removed = true
	elif position.y > 480:
		should_be_removed = true

	position += vel*delta
