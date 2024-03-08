extends VBoxContainer

var home_ui = preload("res://scripts/uis/home.tscn")
var login_ui = preload("res://scripts/uis/login.tscn")

var delete_acc = 3

func _ready():
	$Button.pressed.connect(func(): Hud.change_hud(home_ui.instantiate(), Global.UI_NAMES.HOME))
	for i in range(Global.langs.size()):
		$HBoxContainer/OptionButton.add_item(Global.LANGS_TITLE[Global.langs[i]], i)
	$HBoxContainer/OptionButton.selected = Global.langs.find(Global.lang)
		
func _on_option_button_item_selected(index):
	Global.lang = Global.langs[index]
	TranslationServer.set_locale(Global.lang)
	Global.save_state()

func _on_button_2_pressed():
	delete_acc -= 1
	if delete_acc<=0:
		Global.send_http_request(
			Global.general_server_url + "user/",
			HTTPClient.METHOD_DELETE,
			func(res_data):	
				Global.token = ""
				Global.user_id = ""
				Global.money = 0
				Global.highest_money = 0
				Global.unlocked_progress = 0
				Global.progress = 0
				Global.unlocked_skins = []
				Global.highest_scores = Global.INIT_MINIGAMES
				Global.save_state()
				Hud.change_hud(login_ui.instantiate(), Global.UI_NAMES.LOGIN),
			Global.token, 
			"",
			func():
				pass
		)
