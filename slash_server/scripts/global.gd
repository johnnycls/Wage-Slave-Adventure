extends Node

# secret
const general_server_url = ""
var PW = ""
# slash_server.key

const MAX_PLAYERS = 1000
const PLAYER_N = 4
const AVAILABLE_COST = [500, 5000, 50000, 1000000, 10000000, 100000000]

const MAPS = [
	{
		"players": [
			{
				"pos": Vector3(20, 1.1, 20),
				"rot": Vector3(0, -PI/2, 0),
			},
			{
				"pos": Vector3(20, 1.1, -20),
				"rot": Vector3(0, -PI/2, 0),
			},
			{
				"pos": Vector3(-20, 1.1, 20),
				"rot": Vector3(0, PI/2, 0),
			},
			{
				"pos": Vector3(-20, 1.1, -20),
				"rot": Vector3(0, PI/2, 0),
			},
		], 
		"ground": {
			"pos": Vector3(0, -1, 0),
			"scale": Vector3(54, 2, 54),
		},
		"buildings": [
			{
				"pos": Vector3(0, 5, 26),
				"scale": Vector3(54, 10, 2),
			},
			{
				"pos": Vector3(0, 5, -26),
				"scale": Vector3(54, 10, 2),
			},
			{
				"pos": Vector3(26, 5, 0),
				"scale": Vector3(2, 10, 50),
			},
			{
				"pos": Vector3(-26, 5, 0),
				"scale": Vector3(2, 10, 50),
			},
			{
				"pos": Vector3(-7.5, 5, 12.5),
				"scale": Vector3(15, 10, 5),
			},
			{
				"pos": Vector3(12.5, 5, 12.5),
				"scale": Vector3(5, 10, 5),
			},
			{
				"pos": Vector3(-7.5, 5, 7.5),
				"scale": Vector3(5, 10, 5),
			},
			{
				"pos": Vector3(-10, 5, 2.5),
				"scale": Vector3(10, 10, 5),
			},
			{
				"pos": Vector3(10, 5, -2.5),
				"scale": Vector3(10, 10, 5),
			},
			{
				"pos": Vector3(7.5, 5, 7.5),
				"scale": Vector3(5, 10, 5),
			},
			{
				"pos": Vector3(-12.5, 5, -12.5),
				"scale": Vector3(5, 10, 5),
			},
			{
				"pos": Vector3(7.5, 5, 12.5),
				"scale": Vector3(15, 10, 5),
			},
		],
		"roads": [
			[
				Vector3(-18, 0, -25),
				Vector3(-18, 0, 25),
			],
			[
				Vector3(-25, 0, -18),
				Vector3(25, 0, -18),
			],
			[
				Vector3(18, 0, -25),
				Vector3(18, 0, 25),
			],
			[
				Vector3(25, 0, 18),
				Vector3(-25, 0, 18),
			],
		],
	},
]

var STATS_LEVEL_TO_STATS = {
	"attack": func(level): return 1+0.3*level, 
	"HP": func(level): return 12+3*level, 
	"speed": func(level): return 1+0.4*level, 
	"range": func(level): return 2.5+0.6*level, 
}

func time_event(time, function):
	var timer = Timer.new()
	timer.one_shot = true
	timer.autostart = true
	timer.wait_time = time
	timer.timeout.connect(func():
		function.call()
		timer.queue_free()
	)
	add_child(timer)

func send_http_request(url, method, function, token=null, body=""):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(func(result, response_code, headers, body): 
		if (response_code/100==2):
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var res_data = json.get_data()
			function.call(res_data)
		else:
			pass
		
		http_request.queue_free()
	)
	var headers = ["Authorization: " + token, "Content-Type: application/json"] if token!=null else ["Content-Type: application/json"]
	var error = http_request.request(url, headers, method, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
