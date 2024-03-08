extends Container

var game
var minigames_scene = preload("res://scripts/uis/minigames.tscn")

# change
var game_scene = load("res://scripts/dodgeball/game.tscn")
var game_name = ""

func _ready():
	start() 
	
func start():
	$Start/Label.text = tr("RECORD") + ": " + str(Global.highest_scores[game_name])
	
	if (Global.highest_scores[game_name] < 50):
		$Start/Button2.hide()
	else:
		$Start/Button2.text = tr("START_AT") + ": " + str(int(Global.highest_scores[game_name]/2))
		$Start/Button2.show()
		
	$Start.show()
	$Ongoing.hide() 
	$End.hide()
	
func init(_game):
	game = _game
	game.end_game.connect(end)
	
func _on_button_pressed():
	$Start.hide()
	$Ongoing/Label.text = "0"
	$Ongoing.show()
	game.start(0)

func _on_button_2_pressed():
	$Start.hide()
	$Ongoing/Label.text = str(int(Global.highest_scores[game_name]/2))
	$Ongoing.show()
	game.start(int(Global.highest_scores[game_name]/2))

func update_score(score):
	$Ongoing/Label.text = str(score)

func end(score):
	$Ongoing.hide()
	if score > Global.highest_scores[game_name]:
		$End/CenterContainer/VBoxContainer/Label.show()
		Global.highest_scores[game_name] = score
		Global.save_state()
		Global.update_minigames_highest_score()
	else:
		$End/CenterContainer/VBoxContainer/Label.hide()
	$End/CenterContainer/VBoxContainer/Label2.text = str(score)
	$End.show()

func _on_again_button_pressed():
	game.queue_free()
	Global.main_scene.start_game(game_scene.instantiate())

func _on_back_button_pressed():
	game.queue_free()
	Hud.change_hud(minigames_scene.instantiate(), Global.UI_NAMES.MINIGAMES)
