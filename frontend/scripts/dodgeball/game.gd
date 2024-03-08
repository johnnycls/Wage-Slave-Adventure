extends Node2D

signal end_game(score)

var ui_packed_scene = preload("res://scripts/dodgeball/ui.tscn")
var ball_scene = preload("res://scripts/dodgeball/ball.tscn")
var player_scene = preload("res://scripts/dodgeball/player.tscn")
var thrower_scene = preload("res://scripts/dodgeball/thrower.tscn")

var ui

# 16:9
const SCENE_SIZE = Vector2(1920, 1080)
const UI_NAME = Global.UI_NAMES.DODGEBALL

var is_playing = false
var score = 0

var throwers = []
var balls = []
var player
var zoom_factor

func _screen_pos_to_scene_pos(screen_pos):
	var pos_x = (float(screen_pos.x)-(float(Global.screen_size.x)-float(SCENE_SIZE.x*zoom_factor))/2)/zoom_factor - SCENE_SIZE.x/2
	var pos_y = SCENE_SIZE.y/2 - (float(screen_pos.y)-(float(Global.screen_size.y)-float(SCENE_SIZE.y*zoom_factor))/2)/zoom_factor
	
	return Vector2(pos_x, pos_y)

func _ready():
	is_playing = false
	ui = ui_packed_scene.instantiate() 
	ui.init(self)
	
	Hud.change_hud(ui, UI_NAME)

	zoom_factor = min(Global.screen_size.x/SCENE_SIZE.x, Global.screen_size.y/SCENE_SIZE.y)
	$Camera2D.set_zoom(Vector2(zoom_factor, -zoom_factor))
	
	for i in range(16):
		var x = SCENE_SIZE.x * (i-7.5)/16
		for y in [-SCENE_SIZE.y/2, SCENE_SIZE.y/2]:
			var thrower = thrower_scene.instantiate()
			thrower.init(Vector2(x, y))
			throwers.append(thrower)
			add_child(thrower)
			
	for i in range(9):
		var y = SCENE_SIZE.y * (i-5)/9
		for x in [-SCENE_SIZE.x/2, SCENE_SIZE.x/2]:
			var thrower = thrower_scene.instantiate()
			thrower.init(Vector2(x, y))
			throwers.append(thrower)
			add_child(thrower)
	
	for i in range(5):
		var r = randi_range(0, throwers.size()-1)
		var ball = ball_scene.instantiate()
		ball.init(throwers[r].position, throwers)
		balls.append(ball)
		ball.connect("score", add_score)
		ball.connect("lose", end)
		add_child(ball)
	
	player = player_scene.instantiate()
	add_child(player)

func start(_score):
	is_playing = true
	score = _score
	for ball in balls:
		ball.start(score)
	player.set_speed(score)

func _input(event):
	if (is_playing):
		if event is InputEventScreenTouch or event is InputEventScreenDrag:
			var scene_pos = _screen_pos_to_scene_pos(event.position)
			player.move(scene_pos)

func add_score():
	score += 1
	ui.update_score(score)
	player.set_speed(score)
	for ball in balls:
		ball.get_score()

func end():
	for ball in balls:
		ball.end()
	is_playing = false
	end_game.emit(score)
