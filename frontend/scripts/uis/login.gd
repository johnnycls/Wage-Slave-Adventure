extends MarginContainer

var home_ui = preload("res://scripts/uis/home.tscn")

func _ready():
	$VBoxContainer/HBoxContainer/Button.disabled = true
	$VBoxContainer/HBoxContainer/Button2.disabled = true
	$error_dialog.hide() 
	
	for i in range(Global.langs.size()):
		$VBoxContainer/HBoxContainer2/OptionButton.add_item(Global.LANGS_TITLE[Global.langs[i]], i)
	$VBoxContainer/HBoxContainer2/OptionButton.selected = Global.langs.find(Global.lang)
	
func _login():	
	Global.send_http_request(
		Global.general_server_url + "user/login/",
		HTTPClient.METHOD_POST,
		func(res_data):	
			Global.token = res_data.token 
			Global.user_id = res_data.name
			Global.money = res_data.money
			Global.highest_money = res_data.highest_money
			Global.unlocked_progress = int(res_data.progress)
			Global.progress = int(res_data.progress)
			Global.unlocked_skins = res_data.unlocked_skins.map(func(n): return int(n))
			for key in Global.INIT_MINIGAMES.keys():
				if res_data.highest_scores.has(key):
					Global.highest_scores[key] = res_data.highest_scores[key]
			Global.save_state()

			Hud.change_hud(home_ui.instantiate(), Global.UI_NAMES.HOME),
		null,
		JSON.stringify({"name": $VBoxContainer/LineEdit.text, "password": $VBoxContainer/LineEdit2.text}),
		func():
			$error_dialog.init("Login Error", tr("LOGIN_ERR_DES"), func(): $error_dialog.hide())
			$error_dialog.show()
	)

func _register():
	Global.send_http_request(
		Global.general_server_url + "user/register/",
		HTTPClient.METHOD_POST,
		func(res_data):	
			Global.token = res_data.token 
			Global.user_id = res_data.name
			Global.money = res_data.money
			Global.highest_money = res_data.highest_money
			Global.unlocked_progress = int(res_data.progress)
			Global.progress = int(res_data.progress)
			Global.unlocked_skins = res_data.unlocked_skins.map(func(n): return int(n))
			for key in Global.INIT_MINIGAMES.keys():
				if res_data.highest_scores.has(key):
					Global.highest_scores[key] = res_data.highest_scores[key]
			Global.save_state()

			Hud.change_hud(home_ui.instantiate(), Global.UI_NAMES.HOME),
		null,
		JSON.stringify({"name": $VBoxContainer/LineEdit.text, "password": $VBoxContainer/LineEdit2.text}),
		func():
			$error_dialog.init(tr("REGISTER_ERR"), tr("REGISTER_ERR_DES"), func(): $error_dialog.hide())
			$error_dialog.show()
	)

func _on_line_edit_text_changed(new_text):
	$VBoxContainer/HBoxContainer/Button.disabled = new_text.length() == 0
	$VBoxContainer/HBoxContainer/Button2.disabled = new_text.length() == 0

func _on_line_edit_2_text_changed(new_text):
	$VBoxContainer/HBoxContainer/Button.disabled = new_text.length() == 0
	$VBoxContainer/HBoxContainer/Button2.disabled = new_text.length() == 0


func _on_option_button_item_selected(index):
	Global.lang = Global.langs[index]
	TranslationServer.set_locale(Global.lang)
	Global.save_state()
