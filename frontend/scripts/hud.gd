extends CanvasLayer
signal changed(name, params)

var ui_name

func _ready():
	MobileAds.initialize()
	$MarginContainer.size = Global.screen_size

func change_hud(page, name, params={}):
	for n in $MarginContainer.get_children():
		n.queue_free()
	$MarginContainer.add_child(page)
	ui_name = name
	changed.emit(name, params)
	
	if (name in [Global.UI_NAMES.ACHIEVEMENT, Global.UI_NAMES.PONG, Global.UI_NAMES.SLASH_SET_STATS]):
		$MarginContainer.destroy_ad_view()
	else:
		$MarginContainer.create_ad_view()

func on_disconnected():
	if ui_name == Global.UI_NAMES.SLASH_LOBBY:
		$MarginContainer.get_child(0).on_disconnected()
	elif ui_name == Global.UI_NAMES.SLASH_UI:
		$MarginContainer.get_child(0).on_disconnected()
