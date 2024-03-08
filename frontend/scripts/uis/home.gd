extends VBoxContainer

var levels_ui = preload("res://scripts/uis/levels.tscn")
var transfer_ui = preload("res://scripts/uis/transfer.tscn")
var shop_ui = preload("res://scripts/uis/shop.tscn")
var settings_ui = preload("res://scripts/uis/settings.tscn")
var achievement_ui = preload("res://scripts/uis/achievement.tscn")
var minigames_ui = preload("res://scripts/uis/minigames.tscn")

func _ready():
	Global.update_unlock_level()
	$HBoxContainer/MoneyBtn.text = "$" + str(Global.money/100.0)
	$HBoxContainer/Name.text = Global.user_id

func _on_money_btn_pressed():
	Hud.change_hud(shop_ui.instantiate(), Global.UI_NAMES.SHOP)
	
func _on_start_btn_pressed():
	Hud.change_hud(levels_ui.instantiate(), Global.UI_NAMES.LEVELS)
	
func _on_achievement_btn_pressed():
	Hud.change_hud(achievement_ui.instantiate(), Global.UI_NAMES.ACHIEVEMENT)

func _on_transfer_btn_pressed():
	Hud.change_hud(transfer_ui.instantiate(), Global.UI_NAMES.TRANSFER)

func _on_settings_btn_pressed():
	Hud.change_hud(settings_ui.instantiate(), Global.UI_NAMES.SETTINGS)

func _on_mini_game_btn_pressed():
	Hud.change_hud(minigames_ui.instantiate(), Global.UI_NAMES.MINIGAMES)
