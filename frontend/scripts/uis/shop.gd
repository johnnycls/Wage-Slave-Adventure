extends VBoxContainer

var home_ui = preload("res://scripts/uis/home.tscn")

func _ready():
	$HBoxContainer/Button.pressed.connect(func(): Hud.change_hud(home_ui.instantiate(), Global.UI_NAMES.HOME))
	$HBoxContainer/Label.text = "$" + str(Global.money/100.0)
