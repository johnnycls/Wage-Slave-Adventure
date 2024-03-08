extends Node

# room = {"room_no": 0, "cost": 1, "players": [{"user_id": "", "player_id": "", "stat_levels": {}, "skin": 0]}

var room_queues = {
	"empty": range(Global.MAX_PLAYERS/Global.PLAYER_N+Global.AVAILABLE_COST.size()).map(func (i):
		return {"room_no": i, "players": []}),
}

func _ready():
	for cost in Global.AVAILABLE_COST:
		room_queues[cost] = []

func stat_level_to_stats(stat_levels):
	var stats = {}
	for stat in stat_levels:
		stats[stat] = Global.STATS_LEVEL_TO_STATS[stat].call(stat_levels[stat])
	return stats


func is_stats_valid(stat_levels):
	if (stat_levels.size()!=Global.STATS_LEVEL_TO_STATS.size()):
		return false 
	
	if stat_levels.values().any(func(s): return s<0):
		return false 
		
	if (stat_levels.values().reduce(func(a, s): return a+s)>20):
		return false
		
	return true

func enter_lobby(token, player_id, stat_levels, cost, skin):
	if (not is_stats_valid(stat_levels)):
		multiplayer.disconnect_peer(player_id)
	elif (cost not in Global.AVAILABLE_COST):
		multiplayer.disconnect_peer(player_id)
	else:
		Global.send_http_request(
			Global.general_server_url + "game/money/",
			HTTPClient.METHOD_GET,
			func(res_data): 
				var money = res_data.money
				var user_id = res_data.user_id
				
				if (money < cost):
					multiplayer.disconnect_peer(player_id)
				else:
					var stats = stat_level_to_stats(stat_levels)
					var player = {"user_id": user_id, "player_id": player_id, "stats": stats, "skin": skin}
					if (not room_queues[cost].is_empty()):
						room_queues[cost][0].players.append(player)
						
						if (room_queues[cost][0].players.size()==Global.PLAYER_N):
							var room = room_queues[cost].pop_front()
							room.cost = cost
							_start_game(room)
							
					elif (not room_queues.empty.is_empty()):
						var room = room_queues.empty.pop_front()
						room.players.append(player)
						room_queues[cost].append(room)
						
					else:
						multiplayer.disconnect_peer(player_id),
			token
		)

func leave_lobby(player_id, cost):
	if room_queues[cost].is_empty():
		return
	var room = room_queues[cost][0]
	if (room.players.filter(func(p): return p.player_id==player_id).size()>0 && room.players.size()<Global.PLAYER_N):
		var tmp = room_queues[cost].pop_front()
		tmp.players = tmp.players.filter(func(p): return p.player_id!=player_id)
		if (tmp.players.size()>0):
			room_queues[cost].push_back(tmp)
		else:
			room_queues.empty.push_back({"room_no": room.room_no, "players": []})
		multiplayer.disconnect_peer(player_id)

func _start_game(room):
	$"../Games".start_game(room)
