extends VBoxContainer

var levels_scene = preload("res://scripts/uis/levels.tscn")
var dice_scene = preload("res://scripts/dice/dice.tscn")

func _ready():
	$CenterContainer/HBoxContainer/SpinBox.max_value = Global.money/100
	$CenterContainer/Button.disabled = $CenterContainer/HBoxContainer/SpinBox.value > Global.money/100
	$CenterContainer/Button.pressed.connect(_on_start)
	$Back_Button.pressed.connect(_on_back)

func _on_back(): 
	Hud.change_hud(levels_scene.instantiate(), Global.UI_NAMES.LEVELS)

func _on_start(): 
	var dice = dice_scene.instantiate() 
	dice.init($CenterContainer/HBoxContainer/SpinBox.value*100)
	Hud.change_hud(dice, Global.UI_NAMES.DICE)
