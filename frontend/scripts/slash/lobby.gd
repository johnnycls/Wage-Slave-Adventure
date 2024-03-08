extends VBoxContainer

var set_money_ui = preload("res://scripts/slash/set_money_ui.tscn")

var params
var is_leave = false

func _ready():
	$Button.disabled = false
	$error_dialog.hide()
	$error_dialog.init(tr("LOBBY_ERR"), tr("LOBBY_ERR_DES"), func(): Hud.change_hud(set_money_ui.instantiate(), Global.UI_NAMES.SLASH_UI))
	Hud.connect("changed", on_hud_changed)
	
func init(_params):
	is_leave = false
	params = _params
	
func on_hud_changed(name, _params): 
	if (name == Global.UI_NAMES.SLASH_LOBBY):
		Slash_Server.connect_to_slash_server(params.stats, params.cost)

func _on_button_pressed():
	is_leave = true
	$Button.disabled = true
	Slash_Server.leave_lobby(params.cost)

func on_disconnected():
	if (is_leave):
		Hud.change_hud(set_money_ui.instantiate(), Global.UI_NAMES.SLASH_UI)
	else:
		$error_dialog.show()
