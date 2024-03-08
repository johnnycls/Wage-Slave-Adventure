extends Area2D

signal lose
signal score

const INIT_SPEED = 1000
const SPEED_INC = INIT_SPEED/1000

var throwers = []
var _speed = INIT_SPEED
var _is_playing = false
var target_pos
var direction

func set_target_pos():
	var new_target_pos = throwers[randi_range(0, throwers.size()-1)].position
	while (target_pos.distance_to(new_target_pos) < 0.01):
		new_target_pos = throwers[randi_range(0, throwers.size()-1)].position
	target_pos = new_target_pos
	direction = position.direction_to(target_pos)

func init(pos, _throwers):
	position = pos
	target_pos = position
	throwers = _throwers
	set_target_pos()

func start(score):
	_speed = INIT_SPEED + score * SPEED_INC
	_is_playing = true
	
func get_score():
	_speed += SPEED_INC

func _physics_process(delta):
	if _is_playing:
		var cur_direction = position.direction_to(target_pos)
		if cur_direction.distance_to(direction) < 0.1:
			position += _speed * delta * direction
		else:
			set_target_pos()
			score.emit()

func _on_area_entered(area):
	if area.is_in_group("player"):
		lose.emit()
		
func end():
	_is_playing = false
