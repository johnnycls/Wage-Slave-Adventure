extends VBoxContainer

var buy_scene = preload("res://scripts/dice/buy.tscn")

var ended = false
var money
var buys = [
	[{"rate": 1, "label": tr("BUY_0"), "idx": 0}, {"rate": 1, "label": tr("BUY_1"), "idx": 1}],
	[{"rate": 5, "label": tr("BUY_2"), "idx": 2},],
	[{"rate": 10, "label": tr("BUY_3"), "idx": 3},{"rate": 10, "label": tr("BUY_4"), "idx": 4},{"rate": 10, "label": tr("BUY_5"), "idx": 5},{"rate": 10, "label": tr("BUY_6"), "idx": 6},{"rate": 10, "label": tr("BUY_7"), "idx": 7},{"rate": 10, "label": tr("BUY_8"), "idx": 8},],
	[{"rate": 30, "label": tr("BUY_9"), "idx": 9},],
	[{"rate": 180, "label": tr("BUY_10"), "idx": 10},{"rate": 180, "label": tr("BUY_11"), "idx": 11},{"rate": 180, "label": tr("BUY_12"), "idx": 12},{"rate": 180, "label": tr("BUY_13"), "idx": 13},{"rate": 180, "label": tr("BUY_14"), "idx": 14},{"rate": 180, "label": tr("BUY_15"), "idx": 15},],
]

func _ready():
	$error_dialog.hide()
	$Back_Button.pressed.connect(_on_back)
	$end/Button.pressed.connect(_on_back)
	
	for j in buys: 
		var vbox = VBoxContainer.new()
		var rate_label = Label.new() 
		rate_label.text = str(j[0].rate) 
		vbox.add_child(rate_label)
		
		for i in j:
			var btn = Button.new() 
			btn.text = i.label
			btn.pressed.connect(func(): _on_start(i.idx))
			
			vbox.add_child(btn) 
		
		$ScrollContainer/HBoxContainer2.add_child(vbox)
		
func _process(delta):
	if not ended:
		for label in $HBoxContainer.get_children():
			label.text = str(randi_range(1, 6))

func init(_money):
	money = _money

func _on_back(): 
	Hud.change_hud(buy_scene.instantiate(), Global.UI_NAMES.DICE_BUY)

func _on_start(idx): 
	$Back_Button.disabled = true 
	$ScrollContainer.hide() 
	
	Global.send_http_request(
		Global.general_server_url + "dice/",
		HTTPClient.METHOD_POST,
		func(res_data):
			if (Global.progress == 201):
				Global.progress = 300
				Global.save_state()
				
			var original_money = Global.money
			Global.money = res_data.money
			Global.highest_money = res_data.highest_money
			
			for i in $HBoxContainer.get_child_count():
					$HBoxContainer.get_children()[i].text = str(res_data.results[i]) 
			$end/Label.text = str(original_money/100.0) + " => " + str(res_data.money/100.0)
			
			ended = true
			$end.show(),
		Global.token, 
		JSON.stringify({"money": money, "buyWhat": idx}),
		func():
			$error_dialog.init("Dice Error", "Please check the internet connection", _on_back)
			$error_dialog.show()
	)
