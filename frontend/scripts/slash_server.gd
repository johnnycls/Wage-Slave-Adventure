extends Node

signal start_game(init_data)
signal update_game(new_dynamic_data)
signal end_game(game_results)

var network
var port = 1909 

var stat_levels
var cost

var crypto = Crypto.new()
var key = CryptoKey.new()

var set_money_ui = preload("res://scripts/slash/set_money_ui.tscn")

func _ready():
	key.load("res://slash_server.pub", true)

func connect_to_slash_server(_stat_levels, _cost):
	stat_levels = _stat_levels
	cost = _cost
	
	network = ENetMultiplayerPeer.new()
	
	var error = network.create_client(Global.slash_ip, port)
	if error:
		_on_disconnected(1)
	multiplayer.set_multiplayer_peer(network)
	
	network.connect("peer_connected", _on_connection_succeeded)
	network.connect("peer_disconnected", _on_disconnected)
	
func _on_disconnected(_server_id):
	Hud.on_disconnected()
	
func _on_connection_succeeded(_server_id):
	print("Successfully connected")
	enter_lobby()
	
func enter_lobby():
	var enc_token = crypto.encrypt(key, Global.token.to_utf8_buffer())
	rpc_id(1, "server_enter_lobby", enc_token, stat_levels, cost, Global.skin)

func leave_lobby(cost):
	rpc_id(1, "server_leave_lobby", cost)

func move(rn, event):
	rpc_id(1, "server_move", rn, event)

func slash(rn):
	rpc_id(1, "server_slash", rn)
	
@rpc("authority")
func client_start_game(init_data):
	emit_signal("start_game", init_data)

@rpc("unreliable", "authority")
func client_update_game(new_dynamic_data):
	emit_signal("update_game", new_dynamic_data)

@rpc("authority")
func client_end_game(game_results):
	emit_signal("end_game", game_results)

# Slash_Server functions 
@rpc("any_peer")
func server_enter_lobby(enc_token, stat_levels, cost, skin):
	pass

@rpc("any_peer")
func server_leave_lobby(cost):
	pass 
	
@rpc("unreliable", "any_peer")
func server_move(rn, event):
	pass 
	
@rpc("any_peer")
func server_slash(rn):
	pass
