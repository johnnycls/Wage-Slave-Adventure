extends Node

var network := ENetMultiplayerPeer.new()
var port := 1909

var crypto := Crypto.new()
var key := CryptoKey.new()

func _ready():
	key.load("res://slash_server.key")
	randomize()
	start_server() 
	
func start_server():
	network.create_server(port, Global.MAX_PLAYERS)
	multiplayer.set_multiplayer_peer(network)
	print("Slash Server started")

	network.connect("peer_connected", _peer_connected)
	network.connect("peer_disconnected", _peer_disconnected)

func _peer_connected(player_id):
	print("User " + str(player_id) + " connected")
	
func _peer_disconnected(player_id):
	print("User " + str(player_id) + " disconnected")
	
func send_init_data_to_players(game_state):
	var init_data = {
		"rn": game_state.room_no,
		"m": game_state.map_no,
		"t": game_state.time,
		"p": game_state.players.map(func (p):
			var cleaver = p.get_node("cleaver")
			return {
				"p": p.position,
				"r": p.rotation, 
				"h": p.HP, 
				"m": p.money,
				"n": p.user_id if p.user_id.length()<10 else p.user_id.left(9), 
				"s": p.skin,
				"c": {
					"p": cleaver.position,
					"r": cleaver.rotation,
					"s": cleaver.scale,
				}, 
			}),
		"c": game_state.cars.map(func(c): return {"p": c.position, "r": c.rotation}),
	}
	
	for player_no in range(game_state.players.size()):
		if (game_state.players[player_no].player_id in multiplayer.get_peers()):
			init_data.pn = player_no
			rpc_id(game_state.players[player_no].player_id, "client_start_game", init_data)
		
func send_dynamic_data_to_players(game_state):
	var dynamic_data = {
		"t": game_state.time,
		"p": game_state.players.map(func (p):
			var cleaver = p.get_node("cleaver")
			return {
				"p": p.position,
				"r": p.rotation, 
				"h": p.HP, 
				"m": p.money,
				"c": {
					"p": cleaver.position,
					"r": cleaver.rotation,
				}, 
			}),
		"c": game_state.cars.map(func(c): return c.position),
	}
	
	for player in game_state.players:
		if (player.player_id in multiplayer.get_peers()):
			rpc_id(player.player_id, "client_update_game", dynamic_data)

func send_end_game_to_player(player, cost):
	if (!player.sent_end_data):
		player.sent_end_data = true
		Global.send_http_request(Global.general_server_url + "game/endgame/", 
			HTTPClient.METHOD_POST, 
			func(res_data): pass, 
			null,
			JSON.stringify({"name": player.user_id, "password": Global.PW, "gain_money": player.money-cost}))

		var player_id = player.player_id
		if (player_id in multiplayer.get_peers()):
			rpc_id(player_id, "client_end_game", {})
			Global.time_event(5.0, func():
				if (player_id in multiplayer.get_peers()):
					multiplayer.disconnect_peer(player_id)
				)
	
func send_end_game_to_players(game_state):
	for player in game_state.players:
		send_end_game_to_player(player, game_state.cost)
	$Games.renew_room(game_state.room_no)
	$Lobby.room_queues.empty.append({"room_no": game_state.room_no, "players": []})

@rpc("any_peer")
func server_enter_lobby(enc_token, stat_levels, cost, skin):
	var player_id = multiplayer.get_remote_sender_id()
	var token = crypto.decrypt(key, enc_token).get_string_from_utf8()
	$Lobby.enter_lobby(token, player_id, stat_levels, cost, skin)

@rpc("any_peer")
func server_leave_lobby(cost):
	var player_id = multiplayer.get_remote_sender_id()
	$Lobby.leave_lobby(player_id, cost)

@rpc("unreliable", "any_peer")
func server_move(room_no, event):
	var player_id = multiplayer.get_remote_sender_id()
	$Games.move(player_id, room_no, event)

@rpc("any_peer")
func server_slash(room_no):
	var player_id = multiplayer.get_remote_sender_id()
	$Games.slash(player_id, room_no)

#Client functions 
@rpc("authority")
func client_start_game(init_data):
	pass

@rpc("unreliable", "authority")
func client_update_game(new_dynamic_data):
	pass

@rpc("authority")
func client_end_game(game_results):
	pass
