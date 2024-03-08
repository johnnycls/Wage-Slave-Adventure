extends Node2D

signal end_game(score)

# change
var ui_package_scene = preload("res://scripts/dodgeball/ui.tscn")
const UI_NAME = Global.UI_NAMES.DODGEBALL

var ui

const SCENE_SIZE = Vector2(1920, 1080)

var is_playing = false
var score = 0

func _screen_pos_to_scene_pos(screen_pos):
	var pos_x = (float(screen_pos.x)/float(Global.screen_size.x)-0.5) * float(SCENE_SIZE.x)
	var pos_y = (float(screen_pos.y)/float(Global.screen_size.y)-0.5) * float(SCENE_SIZE.y)
	
	return Vector2(pos_x, pos_y)

func _ready():
	is_playing = false
	ui = ui_package_scene.instantiate() 
	ui.init(self)
	
	Hud.change_hud(ui, UI_NAME)

	var zoom_factor = min(Global.screen_size.x/SCENE_SIZE.x, Global.screen_size.y/SCENE_SIZE.y)
	$Camera2D.set_zoom(Vector2(zoom_factor, -zoom_factor))

func start(_score):
	is_playing = true
	score = _score

func _input(event):
	if (is_playing):
		if event is InputEventScreenTouch or event is InputEventScreenDrag:
			var scene_pos = _screen_pos_to_scene_pos(event.position)

func add_score():
	score += 1
	ui.update_score(score)

func end():
	end_game.emit(score)
