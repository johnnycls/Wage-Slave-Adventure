extends VBoxContainer

var manual_scene = preload("res://scripts/slash/manual.tscn")
var stats = ["ATTACK", "HP", "SPEED", "RANGE"]
var params = {"cost": -1, "stats": {"attack": 0, "HP": 0, "speed": 0, "range": 0}}
var set_money_ui = preload("res://scripts/slash/set_money_ui.tscn")

var btn
var label
var remaining
const STAT_PT = 20

func _ready():
	for i in stats.size():
		var h_box = HBoxContainer.new() 
		h_box.alignment = BoxContainer.ALIGNMENT_CENTER
		h_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var label = Label.new() 
		label.text = tr(stats[i]) 
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_stretch_ratio = 0.1
		h_box.add_child(label)
		
		var h_slider = HSlider.new() 
		h_slider.min_value = 0 
		h_slider.max_value = 10 
		h_slider.ticks_on_borders = true
		h_slider.tick_count = 11 
		h_slider.value = 0
		h_slider.value_changed.connect(func(value): _on_slider_change(params.stats.keys()[i], value))
		h_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h_slider.size_flags_vertical = Control.SIZE_EXPAND_FILL
		h_box.add_child(h_slider)
		
		$ScrollContainer/VBoxContainer.add_child(h_box)
		
	label = Label.new() 
	label.text = tr("PT_REMAINING") + " " + str(STAT_PT)
	add_child(label)
	btn = Button.new() 
	btn.text = tr("START_SLASHING")
	btn.pressed.connect(_on_button_pressed)
	add_child(btn)
	
func init(_params): 
	params.cost = _params.cost

func _on_button_pressed():
	var manual = manual_scene.instantiate()
	manual.init(params)
	Hud.change_hud(manual, Global.UI_NAMES.SLASH_MANUAL)

func _on_slider_change(stat, val):
	params.stats[stat] = val
	remaining = STAT_PT - params.stats.values().reduce(func(a, c): return a+c)
	label.text = tr("PT_REMAINING") + " " + str(remaining)
	btn.disabled = remaining<0

func _on_back_btn_pressed():
	Hud.change_hud(set_money_ui.instantiate(), Global.UI_NAMES.SLASH_SET_MONEY)
