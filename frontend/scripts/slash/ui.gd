extends VBoxContainer

var home_ui = preload("res://scripts/uis/home.tscn")

var labelss = []
var time_label = Label.new()
var timer

func _ready():
	$error_dialog.hide()
	$error_dialog.init(tr("LOBBY_ERR"), tr("LOBBY_ERR_DES"), func(): Hud.change_hud(home_ui.instantiate(), Global.UI_NAMES.HOME))

func init(players, _timer, slash_func):	
	timer = _timer
	for p in players: 
		var labels = []
		var v_box = VBoxContainer.new()
		var name_label = Label.new() 
		name_label.text = str(p.n)
		labels.append(name_label)
		v_box.add_child(name_label)
		
		var hp_label = Label.new() 
		hp_label.text = tr("HP") + str(p.h)
		labels.append(hp_label)
		v_box.add_child(hp_label)
		
		var money_label = Label.new() 
		money_label.text = "$" + str(p.m/100.0)
		labels.append(money_label)
		v_box.add_child(money_label)
		
		labelss.append(labels)
		$HBoxContainer.add_child(v_box)
		
	var gap = Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND
	$HBoxContainer.add_child(gap)
	$HBoxContainer.add_child(time_label)
	
	$MarginContainer/SlashBtn.pressed.connect(slash_func)
	
func update(players):
	for i in players.size():
		labelss[i][1].text = tr("HP") + str(players[i].h)
		labelss[i][2].text = "$" + str(players[i].m/100.0)

func _process(delta):
	time_label.text = str(int(timer.time_left))

func on_disconnected():
	$error_dialog.show()
