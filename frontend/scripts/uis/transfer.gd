extends VBoxContainer

var home_ui = preload("res://scripts/uis/home.tscn")

func _ready():
	$HBoxContainer/Button.pressed.connect(func(): Hud.change_hud(home_ui.instantiate(), Global.UI_NAMES.HOME))
	$HBoxContainer/Label.text = "$" + str(Global.money/100.0)
	$error_dialog.hide() 

func _transfer():	
	Global.send_http_request(
		Global.general_server_url + "user/transfer/",
		HTTPClient.METHOD_POST,
		func(res_data):
			Global.money = res_data.money
			Hud.change_hud(home_ui.instantiate(), Global.UI_NAMES.HOME),
		Global.token,
		JSON.stringify({"receiver_name": $CenterContainer/VBoxContainer/LineEdit.text, "money": $CenterContainer/VBoxContainer/SpinBox.value*100}),
		func():
			$error_dialog.init(tr("TRANS_ERR"), tr("TRANS_ERR_DES"), func(): Hud.change_hud(home_ui.instantiate(), Global.UI_NAMES.HOME))
			$error_dialog.show()
	)

func _on_spin_box_value_changed(value):
	if value>float(Global.money/100):
		$CenterContainer/VBoxContainer/Button.disabled = true 
	else:
		$CenterContainer/VBoxContainer/Button.disabled = false
