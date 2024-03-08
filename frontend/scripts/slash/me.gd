extends "player.gd"

var pan_move_speed: float = 0.004
var last_rot: Vector3 = rotation

func init(_player_no, player_data, _room_no):
	player_no = _player_no
	room_no = _room_no
	position = player_data.p
	rotation = player_data.r 
	$cleaver.init(room_no, player_data.c)

func _input(event):
	var _event = {"type": -1}
	if event is InputEventScreenTouch and event.position.x < Global.screen_size.x/2:
		if (event.pressed):
			_event.type = 0
			_event.position = event.position
		else: 
			_event.type = 1
	elif event is InputEventScreenDrag:
		if (event.position.x < Global.screen_size.x/2):
			_event.type = 2
			_event.position = event.position
		else:
			_event.type = 3
			last_rot = last_rot - Vector3(0, event.relative.x * pan_move_speed, 0)
			_event.rotation = last_rot
	else:
		return
	Slash_Server.move(room_no, _event)

func slash():
	$cleaver.slash()

func update_state(player_data):
	position = player_data.p
	rotation = player_data.r 
