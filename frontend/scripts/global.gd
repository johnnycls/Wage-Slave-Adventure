extends Node

# CHAPTER_3, UNLOCK_300, STORY_300_

# secret
const general_server_url = ""
const slash_ip = ""
#const slash_ip = "127.0.0.1"
const android_unit_id = ""
const ios_unit_id = ""
const android_banner_unit_id = ""
const ios_banner_unit_id = ""

const SKINS = [
	{"color": "FFFFFF"}
]

const UNLOCK = {
	0: 1, 
	1: 100,
	100: 101, 
	101: 200,
	200: 201,
	201: 300,
	300: 301,
	301: 400,
}

const UNLOCK_CONDITIONS = {
  0: 0,
  1: 0,
  100: 0,
  101: 0,
  200: 10000,
  201: 10000,
  300: 20000,
  301: 20000,
  400: 20000,
}

const UI_NAMES = {
	"ACHIEVEMENT": "ACHIEVEMENT",
	"DICE": "DICE",
	"DICE_BUY": "DICE_BUY", 
	"DODGEBALL": "DODGEBALL",
	"HOME": "HOME",
	"LEVELS": "LEVELS",
	"LOADING": "LOADING",
	"LOGIN": "LOGIN",
	"MINIGAMES": "MINIGAMES",
	"NOTHING": "NOTHING",
	"PONG": "PONG",
	"SETTINGS": "SETTINGS",
	"SHOP": "SHOP",
	"SLASH_LOBBY": "SLASH_LOBBY",
	"SLASH_MANUAL": "SLASH_MANUAL",
	"SLASH_RESULTS": "SLASH_RESULTS",
	"SLASH_SET_MONEY": "SLASH_SET_MONEY",
	"SLASH_SET_STATS": "SLASH_SET_STATS",
	"SLASH_UI": "SLASH_UI",
	"SNAKE": "SNAKE",
	"STORY": "STORY",
	"TRANSFER": "TRANSFER",
	"WORK": "WORK",
}

var INIT_MINIGAMES = {
	"pong": 0,
	"dodgeball": 0,
	"snake": 0,
}

var main_scene
var screen_size = DisplayServer.window_get_size()
var token = ""
var user_id = ""
var money = 0 
var highest_money = 0 
var progress = 0
var unlocked_progress = 0
var unlocked_skins = []
var skin = SKINS[0]
var highest_scores = INIT_MINIGAMES

const LANGS_TITLE = {"cmn": "簡體中文", "en": "English", "zh": "繁體中文(香港)"}
var langs = TranslationServer.get_loaded_locales()
var lang = TranslationServer.get_locale()

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

func _ready():
	randomize()

func save_state():
	var gamedata = {"token": token, "user_id": user_id, "lang": lang, "progress": progress, "highest_scores": highest_scores}
	var gamedata_file = FileAccess.open("user://gamedata.save", FileAccess.WRITE)
	var gamedata_json = JSON.stringify(gamedata)
	gamedata_file.store_string(gamedata_json)

func update_unlock_level():
	if (int(progress) > int(unlocked_progress)) and (int(progress) in UNLOCK_CONDITIONS) and (money >= UNLOCK_CONDITIONS[int(progress)]):
		send_http_request(
			general_server_url + "user/unlocklevel", 
			HTTPClient.METHOD_POST, 
			func(res_data):
				Global.unlocked_progress = int(res_data.progress), 
			token, 
			JSON.stringify({"unlocked_level": progress})
		)
		
func update_minigames_highest_score():		
	send_http_request(
		general_server_url + "user/minigames", 
		HTTPClient.METHOD_POST, 
		func(res_data):
			highest_scores = res_data.highest_scores, 
		token, 
		JSON.stringify({"highest_scores": highest_scores})
	)

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

func send_http_request(url, method, function, token=null, body="", fail_function=func(): pass):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(func(result, response_code, headers, body): 
		if (response_code/100==2):
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var res_data = json.get_data()
			function.call(res_data)
		else:
			fail_function.call()
		
		http_request.queue_free()
	)
	var headers = ["Authorization: " + token, "Content-Type: application/json"] if token!=null else ["Content-Type: application/json"] 
	var error = http_request.request(url, headers, method, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		fail_function.call()
