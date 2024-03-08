extends CenterContainer

var home_ui = preload("res://scripts/uis/home.tscn")
var login_ui = preload("res://scripts/uis/login.tscn")
var saved_data
var http_request

func _ready():
	if not FileAccess.file_exists("user://gamedata.save"):
		Hud.change_hud(login_ui.instantiate(), Global.UI_NAMES.LOGIN)
		return 
		
	var saved_data_file = FileAccess.open("user://gamedata.save", FileAccess.READ)
	var json_string = saved_data_file.get_as_text()
	saved_data = JSON.new()
	var error = saved_data.parse(json_string)
	if not error == OK:
		print("JSON Parse Error: ", saved_data.get_error_message(), " in ", json_string, " at line ", saved_data.get_error_line())
		Hud.change_hud(login_ui.instantiate(), Global.UI_NAMES.LOGIN)
		return 
	
	saved_data = saved_data.get_data()
	if (typeof(saved_data) != TYPE_DICTIONARY or not saved_data.has("token")):
		Hud.change_hud(login_ui.instantiate(), Global.UI_NAMES.LOGIN)
		return 
		
	Global.send_http_request(
		Global.general_server_url + "user/",
		HTTPClient.METHOD_GET,
		func(res_data):
			Global.progress = int(saved_data.progress) if (saved_data.has("progress")) else int(res_data.progress)
			if (saved_data.has("lang")):
				Global.lang = saved_data.lang
				TranslationServer.set_locale(saved_data.lang) 
			Global.token = saved_data.token
			for key in Global.INIT_MINIGAMES.keys():
				if saved_data.has("highest_scores") and saved_data.highest_scores.has(key):
					Global.highest_scores[key] = saved_data.highest_scores[key]
			
			Global.user_id = res_data.name
			Global.money = res_data.money
			Global.highest_money = res_data.highest_money
			Global.unlocked_progress = int(res_data.progress)
			Global.unlocked_skins = res_data.unlocked_skins.map(func(n): return int(n))
			
			var need_update_minigame = false
			for key in res_data.highest_scores.keys():
				if res_data.highest_scores[key] > Global.highest_scores[key]:
					Global.highest_scores[key] = res_data.highest_scores[key]
				elif res_data.highest_scores[key] < Global.highest_scores[key]:
					need_update_minigame = true
			if need_update_minigame:
				Global.update_minigames_highest_score()
			
			if (int(res_data.progress) > int(Global.progress)):
				Global.progress = int(res_data.progress)
				Global.save_state()
			
			Global.update_unlock_level()
			Hud.change_hud(home_ui.instantiate(), Global.UI_NAMES.HOME),
		saved_data.token,
		"",
		func(): 
			Hud.change_hud(login_ui.instantiate(), Global.UI_NAMES.LOGIN)
	)
