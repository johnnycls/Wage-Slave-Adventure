extends Area2D

var left_bound 
var right_bound

func init(_left_bound, _right_bound, y):
	left_bound = _left_bound
	right_bound = _right_bound
	position = Vector2((left_bound+right_bound)/2, y)
	$CollisionShape2D.position = Vector2(0, -20)
	
func move(pos_x):
	position.x = pos_x
