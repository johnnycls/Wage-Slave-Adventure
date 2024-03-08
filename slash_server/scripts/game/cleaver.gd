extends Area3D

var attack: float = 0.0
var isSlashing: bool = false
var t: float = 0.0
var slashing_speed: float = 5.0
var cooling_time: float = 0.1
var start_pos: Vector3
var start_rot: Vector3 = Vector3(-80*PI/180, 0, 10*PI/180)
var end_pos: Vector3
var end_rot: Vector3 = Vector3(-10*PI/180, 0, 10*PI/180)

func init(_scale, _attack):
	start_pos = Vector3(-0.03015, 0.98481, 0.17101) * _scale.z*0.3/2 + Vector3(-0.2, 0.9, 0.2)
	end_pos = Vector3(0.03015, 0.17101, 0.98481) * _scale.z*0.3/2 + Vector3(0.7, 0, 0.4)
	position = start_pos
	rotation = start_rot
	scale = _scale
	attack = _attack
	

func _physics_process(delta):
	if (isSlashing):
		t += delta * slashing_speed 
		position = start_pos.lerp(end_pos, t)
		rotation = start_rot.lerp(end_rot, t)
	if (t >= 1+cooling_time):
		position = start_pos
		rotation = start_rot
		isSlashing = false
		t = 0.0


func slash(): 
	if (not isSlashing): 
		isSlashing = true 
		t = 0.0


func _on_body_entered(body):
	if body.is_in_group("players"):
		body.hit(attack, get_parent())
