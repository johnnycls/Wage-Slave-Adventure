extends Area2D

const INIT_SPEED = 10

var _speed = INIT_SPEED
var _speed_inc = INIT_SPEED/1000
var target_pos = Vector2(0,0)

func _ready():
	position = Vector2(0, 0)
	
func set_speed(score):
	_speed = score*_speed_inc + INIT_SPEED
	
func _physics_process(delta):
	position = position.lerp(target_pos, min(delta*_speed, 1))
	
func move(_target_pos):
	target_pos = _target_pos
