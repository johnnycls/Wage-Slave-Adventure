extends Node

#MINIGAME_PTS

var loading_ui = preload("res://scripts/uis/loading.tscn")
var slash_game = preload("res://scripts/slash/game.tscn")
var slash_results_scene = preload("res://scripts/slash/results_ui.tscn")

var game

func _ready():
	Global.main_scene = self
	Hud.change_hud(loading_ui.instantiate(), Global.UI_NAMES.LOADING)
	
	Slash_Server.connect("start_game", _start_slash)
	Slash_Server.connect("update_game", _update_slash)
	Slash_Server.connect("end_game", _end_slash)

func _start_slash(init_data):
	game = slash_game.instantiate()
	game.init(init_data)
	
func _update_slash(new_dynamic_data):
	if (game != null):
		game.update_game(new_dynamic_data)

func _end_slash(game_results):
	var slash_results = slash_results_scene.instantiate()
	if (game != null):
		var results = range(game.init_data.p.size()).map(func(i):
			return {
				"name": game.init_data.p[i].n,
				"hp": game.dynamic_data.p[i].h,
				"money": game.dynamic_data.p[i].m,
			}
		)
		slash_results.init(results)
		game.queue_free()
	Hud.change_hud(slash_results, Global.UI_NAMES.SLASH_RESULTS)

func start_game(game_scene):
	game = game_scene
	add_child(game)
