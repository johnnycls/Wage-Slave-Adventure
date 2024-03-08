extends Node2D

signal end_game(score)

var pong_ui = preload("res://scripts/pong/ui.tscn")
var ball = preload("res://scripts/pong/ball.tscn")
var paddle = preload("res://scripts/pong/paddle.tscn")

var ui

const N = 2 
const SCENE_SIZE = Vector2(1920, 1080)

var balls = []
var paddles = []

var is_playing = false
var score = 0

func _ready():
	is_playing = false
	ui = pong_ui.instantiate() 
	ui.init(self)
	
	Hud.change_hud(ui, Global.UI_NAMES.PONG)

	var zoom_factor = min(Global.screen_size.x/SCENE_SIZE.x, Global.screen_size.y/SCENE_SIZE.y)
	$Camera2D.set_zoom(Vector2(zoom_factor, -zoom_factor))
	
	for i in range(N):
		var left_bound = (float(i)/float(N) - 0.5) * SCENE_SIZE.x
		var right_bound = ((float(i)+1.0)/float(N) - 0.5) * SCENE_SIZE.x

		var b = ball.instantiate()
		b.init(Vector2((left_bound+right_bound)/2, float(SCENE_SIZE.y)*3.0/8.0), score, SCENE_SIZE)
		b.connect("score", add_score)
		b.connect("lose", end)
		add_child(b)
		balls.append(b)
		
		var p = paddle.instantiate()
		p.init(left_bound, right_bound, -SCENE_SIZE.y*2/5)
		add_child(p)
		paddles.append(p)

func start(_score):
	is_playing = true
	score = _score
	
	for b in balls:
		b.set_score(score)
		b.start()

func _input(event):
	if (is_playing):
		if event is InputEventScreenTouch or event is InputEventScreenDrag:
			var pos_x = (float(event.position.x)/float(Global.screen_size.x)-0.5) * float(SCENE_SIZE.x)
			for p in paddles:
				if pos_x >= p.left_bound and pos_x <= p.right_bound:
					var move_to = (pos_x-p.left_bound)/float(p.right_bound-p.left_bound)*float(SCENE_SIZE.x) - 0.5*float(SCENE_SIZE.x)
					p.move(move_to)
					return

func add_score():
	score += 1
	ui.update_score(score)

func end():
	end_game.emit(score)
	for b in balls:
		b.end()
