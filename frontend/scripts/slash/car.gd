extends Node3D

var car_no

func init(_car_no, car_data):
	car_no = _car_no
	position = car_data.p
	rotation = car_data.r 

func update_state(car_pos):
	position = car_pos
