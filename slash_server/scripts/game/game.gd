extends Node

var player_scene = preload("res://scripts/game/player.tscn")
var car_scene = preload("res://scripts/game/car.tscn")

var game_state = {}
var map = {}
var cost = -1
var dead_n = 0
var is_init_finished = false

var time = 0.0

func _ready():
	is_init_finished = false

func init(room):
	dead_n = 0
	cost = room.cost
	var map_no = randi_range(0, Global.MAPS.size()-1)
	map = Global.MAPS[map_no]
	$map.create_map(Global.MAPS[map_no].ground, Global.MAPS[map_no].buildings)
	var players = []
	
	for i in range(room.players.size()):
		var player = player_scene.instantiate()
		player.init({
			"player_id": room.players[i].player_id,
			"user_id": room.players[i].user_id,
			"skin": 0,
			"stats": room.players[i].stats,
			"pos": map.players[i].pos,
			"rot": map.players[i].rot,
			"HP": room.players[i].stats.HP,
			"money": cost,
			"cleaver": {
				"scale": Vector3(1, 1, room.players[i].stats.range),
			},
		})
		players.push_back(player)
		add_child(player)
	
	var cars = []
	for road in Global.MAPS[map_no].roads:
		var car = car_scene.instantiate() 
		car.init(road)
		cars.push_back(car)
		add_child(car)
		
	game_state = {
		"room_no": room.room_no,
		"ground": map.ground,
		"buildings": map.buildings,
		"roads": map.roads,
		"time": 180.0,
		"cars": cars,
		"players": players, 
		"map_no": map_no,
		"cost": cost,
	}
	$"../../../Slash_Server".send_init_data_to_players(game_state)
	$Timer.start()
	is_init_finished = true
	
func _process(delta):
	if is_init_finished:
		time += delta
		if (time >= 0.04):
			$"../../../Slash_Server".send_dynamic_data_to_players(game_state)
			time = 0
		
func end_game():
	$Timer.stop()
	$"../../../Slash_Server".send_end_game_to_players(game_state)
	
func dead(player):
	$"../../../Slash_Server".send_end_game_to_player(player, cost)
	dead_n += 1
	if dead_n>=Global.PLAYER_N-1:
		end_game()

func move(player_id, event):
	var players = game_state.players.filter(func (p):
		return p.player_id==player_id
	)
	if (players.size() > 0):
		players[0].move(event)

func slash(player_id):
	var players = game_state.players.filter(func (p):
		return p.player_id==player_id
	)
	if (players.size() > 0):
		players[0].slash()

func _on_timer_timeout():
	end_game()
