extends CharacterBody3D

var player_no
var room_no

func init(_player_no, player_data, _room_no):
	player_no = _player_no
	room_no = _room_no
	position = player_data.p
	rotation = player_data.r 
	$cleaver.init(room_no, player_data.c)
	$Label3D.text = player_data.n

func update_state(player_data):
	position = player_data.p
	rotation = player_data.r 
	$cleaver.update(player_data.c)
