extends Area3D

var room_no = -1

func init(_room_no, cleaver_data):
	room_no = _room_no
	position = cleaver_data.p
	rotation = cleaver_data.r
	scale = cleaver_data.s

func update(cleaver_data):
	position = cleaver_data.p
	rotation = cleaver_data.r
