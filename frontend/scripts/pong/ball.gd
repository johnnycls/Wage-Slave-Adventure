extends Area2D

signal lose
signal score

const INIT_SPEED = 800
const SPEED_INC = 15

var _speed = INIT_SPEED
var direction = Vector2.DOWN

var is_playing = false
var scene_size

func start():
	is_playing = true

func init(pos, score, _scene_size):
	position = pos
	_speed = INIT_SPEED + score * SPEED_INC / 2
	scene_size = _scene_size
	
func set_score(score):
	_speed = INIT_SPEED + score * SPEED_INC / 2

func _physics_process(delta):
	if (is_playing):
		position += _speed * delta * direction
		if (position.x < -scene_size.x/2):
			direction = direction.rotated(randf_range(-PI/10.0, PI/10.0))
			direction.x = abs(direction.x)
		if (position.x > scene_size.x/2):
			direction = direction.rotated(randf_range(-PI/10.0, PI/10.0))
			direction.x = -abs(direction.x)
		if (position.y > scene_size.y/2):
			direction = direction.rotated(randf_range(-PI/10.0, PI/10.0))
			direction.y = -abs(direction.y)
		if (position.y < -scene_size.y/2):
			is_playing = false
			lose.emit()

func _on_area_entered(area):
	if (area.is_in_group("paddle")):
		direction = direction.rotated(randf_range(-PI/10.0, PI/10.0))
		direction.y = abs(direction.y)
		_speed += SPEED_INC
		score.emit()
	elif (area.is_in_group("ball")):
		direction = -direction
		direction = direction.rotated(randf_range(-PI/10.0, PI/10.0))

func end():
	is_playing = false

