extends CenterContainer

var home = preload("res://scripts/uis/home.tscn")

func title(highest_money):
	if (highest_money >= 100000000):
		return tr("DIAMOND")
	if (highest_money >= 10000000):
		return tr("GOLD")
	if (highest_money >= 1000000):
		return tr("SILVER")
	if (highest_money >= 100000):
		return tr("BRONZE")
	if (highest_money >= 10000):
		return tr("IRON")
	return tr("STONE")

func _ready():
	$VBoxContainer/Title.text = title(Global.highest_money)
	$VBoxContainer/Name.text = Global.user_id
	$VBoxContainer/Highest.text = tr("HIGHEST") + str(Global.highest_money/100)

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		Hud.change_hud(home.instantiate(), Global.UI_NAMES.HOME)
