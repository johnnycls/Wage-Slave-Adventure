extends VBoxContainer

var home = preload("res://scripts/uis/home.tscn")
var pong_game = preload("res://scripts/pong/game.tscn")
var dodgeball_game = preload("res://scripts/dodgeball/game.tscn")
var snake_game = preload("res://scripts/snake/game.tscn")
var minigame_points = 0

var games = [
	[
		{"label": tr("PONG"), "game_scene": pong_game, "condition": {"game": "pong", "score": 0, "label": ""}},
		{"label": tr("DODGEBALL"), "game_scene": dodgeball_game, "condition": {"game": "pong", "score": 40, "label": tr("UNLOCK_DODGEBALL")}},
	],
	[
		{"label": tr("SNAKE"), "game_scene": snake_game, "condition": {"game": "dodgeball", "score": 200, "label": tr("UNLOCK_SNAKE")}, "color": Color(0.88,0.26,0.26)},
	]
]

func _on_button_pressed():
	Hud.change_hud(home.instantiate(), Global.UI_NAMES.HOME)
	
func _ready():
	for i in range(games.size()):
		var container = HBoxContainer.new()
		container.add_theme_constant_override("separation", 20)
		for j in range(games[i].size()):
			var btn = Button.new()
			btn.text = games[i][j].label if Global.highest_scores[games[i][j].condition.game] >= games[i][j].condition.score else tr("LOCKED")
			btn.pressed.connect(func(): _on_game_pressed(i, j))
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			if games[i][j].has("color"):
				var style_box = StyleBoxFlat.new()
				style_box.bg_color = games[i][j].color
				btn.add_theme_stylebox_override("normal", style_box)
				
			container.add_child(btn)
		$ScrollContainer/VBoxContainer.add_child(container)
		
	minigame_points = Global.highest_scores.pong/40 + Global.highest_scores.dodgeball/200 + Global.highest_scores.snake/50
	$HBoxContainer/Label.text = tr("MINIGAME_PTS") + ": " + str(minigame_points)
	
func _on_game_pressed(i, j):
	if Global.highest_scores[games[i][j].condition.game] >= games[i][j].condition.score:
		Global.main_scene.start_game(games[i][j].game_scene.instantiate())
	else:
		$error_dialog.init(games[i][j].label, games[i][j].condition.label, func(): $error_dialog.hide())
		$error_dialog.show()
