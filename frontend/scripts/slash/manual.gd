extends VBoxContainer

var params
var lobby_scene = preload("res://scripts/slash/lobby.tscn")

func init(_params):
	params = _params

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		var lobby = lobby_scene.instantiate()
		lobby.init(params)
		Hud.change_hud(lobby, Global.UI_NAMES.SLASH_LOBBY)
