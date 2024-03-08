extends Node

var player = preload("res://scripts/slash/player.tscn")
var me_scene = preload("res://scripts/slash/me.tscn")
var car = preload("res://scripts/slash/car.tscn")
var slash_ui = preload("res://scripts/slash/ui.tscn").instantiate()

var players = []
var cars = []
var init_data
var dynamic_data

func init(_init_data):
	if (Global.progress == 101):
		Global.progress = 200
		Global.save_state()
		
	init_data = _init_data
	$map.create_map(Global.MAPS[init_data.m].ground, Global.MAPS[init_data.m].buildings)
	_instantiate_p()
	_instantiate_cars()
	Hud.change_hud(slash_ui, Global.UI_NAMES.SLASH_UI)
	$Timer.wait_time = init_data.t
	$Timer.autostart = true
	
func _instantiate_p():
	for player_no in range(init_data.p.size()):
		if (player_no == init_data.pn):
			var me = me_scene.instantiate()
			me.init(player_no, init_data.p[player_no], init_data.rn)
			players.append(me)
			add_child(me)
			slash_ui.init(init_data.p, $Timer, func(): me.slash())
		else:
			var player = player.instantiate()
			player.init(player_no, init_data.p[player_no], init_data.rn)
			players.append(player)
			add_child(player)
			
func _instantiate_cars():
	for car_no in range(init_data.c.size()):
		var car = car.instantiate()
		car.init(car_no, init_data.c[car_no])
		cars.append(car)
		add_child(car)

func update_game(new_dynamic_data):
	dynamic_data = new_dynamic_data
	slash_ui.update(dynamic_data.p)
	for player_no in players.size():
		if (dynamic_data.p[player_no].h<=0):
			players[player_no].hide()
		players[player_no].update_state(dynamic_data.p[player_no])
	for car_no in cars.size():
		cars[car_no].update_state(dynamic_data.c[car_no])
	if (dynamic_data.p[init_data.pn].h<=0):
		pass
