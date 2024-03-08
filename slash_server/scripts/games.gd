extends Node

var game_scene = preload("res://scripts/game/game.tscn")

var rooms = []

func _ready():
	rooms = range(Global.MAX_PLAYERS/Global.PLAYER_N+Global.AVAILABLE_COST.size()).map(func(n):
		var game = game_scene.instantiate()
		add_child(game)
		return game
	)

func start_game(room):	
	rooms[room.room_no].init(room)

func move(player_id, room_no, event):
	rooms[room_no].move(player_id, event) 
	
func slash(player_id, room_no):
	rooms[room_no].slash(player_id)

func renew_room(room_no):
	var original_room = rooms[room_no]
	var new_room = game_scene.instantiate()
	add_child(new_room)
	rooms[room_no] = new_room
	original_room.queue_free()
