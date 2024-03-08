extends Area3D

var road
var direction
var distance
var damage = 2
var velocity = Vector3(0,0,0)

func init(_road):
	road = _road
	direction = (_road[1] - _road[0]).normalized()
	rotation = direction*PI/2
	distance = _road[0].distance_to(_road[1])
	start()
	
func start():
	position = road[0]
	var speed = randf_range(10, 35)
	velocity = speed * direction 
	var time = distance / speed + randf_range(2, 5)
	$Timer.wait_time = time 
	$Timer.autostart = true
	
func _physics_process(delta):
	position += velocity * delta

func _on_timer_timeout():
	start()

func _on_body_entered(body):
	if body.is_in_group("players"):
		body.hit(damage, self)
