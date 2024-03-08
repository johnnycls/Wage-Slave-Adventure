extends VBoxContainer

var levels_scene = preload("res://scripts/uis/levels.tscn")

var PERFORMANCE = range(4).map(func(i): return [{"dialog": tr("STORY_1_" + str(i))}])
var performance
var cur = -1

func _ready():
	$Label.text = str(Global.money/100.0)
	$error_dialog.hide()
	$Loading.show()
	
	Global.send_http_request(
		Global.general_server_url + "work/",
		HTTPClient.METHOD_GET,
		func(res_data): 
			if (Global.progress == 1):
				Global.progress = 100
				Global.update_unlock_level()
				Global.save_state()
					
			performance = PERFORMANCE[res_data.performance]
			Global.money = res_data.money
			Global.highest_money = res_data.highest_money
			cur = -1
			$Loading.hide()
			next(),
		Global.token,
		"",
		func():
			$error_dialog.show()
	)
	
func next(): 
	if performance:
		cur += 1
		if (cur >= performance.size()):
			Hud.change_hud(levels_scene.instantiate(), Global.UI_NAMES.LEVELS)
		else: 	
			$CenterContainer/Label.text = performance[cur].dialog
	
func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		next()
