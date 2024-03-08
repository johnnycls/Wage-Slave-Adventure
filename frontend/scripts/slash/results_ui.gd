extends VBoxContainer

var home_scene = preload("res://scripts/uis/home.tscn")

func init(players):
	Global.update_unlock_level()
	for player in players:
		var label1 = Label.new() 
		label1.text = player.name
		var label2 = Label.new() 
		label2.text = str(player.hp)
		var label3 = Label.new() 
		label3.text = "$" + str(player.money/100.0)
		$HBoxContainer/VBoxContainer.add_child(label1)
		$HBoxContainer/VBoxContainer2.add_child(label2)
		$HBoxContainer/VBoxContainer3.add_child(label3)

func _on_button_pressed():
	Hud.change_hud(home_scene.instantiate(), Global.UI_NAMES.HOME)
