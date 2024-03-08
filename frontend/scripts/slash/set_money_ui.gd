extends VBoxContainer

var costs = [500, 5000, 50000, 1000000, 10000000, 100000000]
var set_stats_ui = preload("res://scripts/slash/set_stats_ui.tscn")
var levels = preload("res://scripts/uis/levels.tscn")

func _ready():
	for cost in costs:
		var button = Button.new()
		button.text = "$" + str(cost/100.0)
		button.disabled = cost>Global.money
		button.pressed.connect(func (): on_button_pressed(cost))
		$CenterContainer/VBoxContainer.add_child(button)
		
func on_button_pressed(cost):
	var ui = set_stats_ui.instantiate()
	ui.init({"cost": cost})
	Hud.change_hud(ui, Global.UI_NAMES.SLASH_SET_STATS)

func _on_back_btn_pressed():
	Hud.change_hud(levels.instantiate(), Global.UI_NAMES.LEVELS)
