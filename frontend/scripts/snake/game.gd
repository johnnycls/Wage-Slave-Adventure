extends Node2D

signal end_game(score)

# change
var ui_package_scene = preload("res://scripts/snake/ui.tscn")
const UI_NAME = Global.UI_NAMES.SNAKE

var ui

const SCENE_SIZE = Vector2(1920, 1080)
var zoom_factor

var snake_scene = preload("res://scripts/snake/snake.tscn")
var snake
var fruit_scene = preload("res://scripts/snake/fruit.tscn")

var is_playing = false
var score = 0

func _screen_pos_to_scene_pos(screen_pos):
	var pos_x = (float(screen_pos.x)-(float(Global.screen_size.x)-float(SCENE_SIZE.x*zoom_factor))/2)/zoom_factor - SCENE_SIZE.x/2
	var pos_y = (float(screen_pos.y)-(float(Global.screen_size.y)-float(SCENE_SIZE.y*zoom_factor))/2)/zoom_factor - SCENE_SIZE.y/2
	
	return Vector2(pos_x, pos_y)

func _ready():
	var curve = Curve2D.new()
	curve.add_point(Vector2(-SCENE_SIZE.x/2-100, -SCENE_SIZE.y/2-100))
	curve.add_point(Vector2(SCENE_SIZE.x/2+100, -SCENE_SIZE.y/2-100))
	curve.add_point(Vector2(SCENE_SIZE.x/2+100, SCENE_SIZE.y/2+100))
	curve.add_point(Vector2(-SCENE_SIZE.x/2-100, SCENE_SIZE.y/2+100))
	$Path2D.set_curve(curve)
	
	is_playing = false
	ui = ui_package_scene.instantiate() 
	ui.init(self)
	
	Hud.change_hud(ui, UI_NAME)

	zoom_factor = min(Global.screen_size.x/SCENE_SIZE.x, Global.screen_size.y/SCENE_SIZE.y)
	$Camera2D.set_zoom(Vector2(zoom_factor, zoom_factor))
	
	snake = snake_scene.instantiate()
	snake.init(end, SCENE_SIZE)
	add_child(snake)

func start(_score):
	is_playing = true
	score = _score
	snake.start(score)
	$Timer.start()
	$AudioStreamPlayer.play()

func _input(event):
	if (is_playing):
		if (event is InputEventScreenTouch and event.pressed) or event is InputEventScreenDrag:
				var scene_pos = _screen_pos_to_scene_pos(event.position)
				snake.set_target_pos(scene_pos)
		elif event is InputEventScreenTouch and (not event.pressed):
				snake.stop()

func add_score():
	score += 1
	snake.get_score()
	ui.update_score(score)
	$Timer.wait_time = max(0.1, $Timer.get_wait_time()-score/200)
	$AudioStreamPlayer2.play()
	

func end():
	$Timer.stop()
	get_tree().call_group("fruits", "queue_free")
	end_game.emit(score)
	$AudioStreamPlayer.stop()

func _on_timer_timeout():
	var fruit = fruit_scene.instantiate()
	var fruit_spawn_location = $Path2D/PathFollow2D
	fruit_spawn_location.progress_ratio = randf()
	var direction = fruit_spawn_location.rotation + PI/2
	fruit.position = fruit_spawn_location.position
	direction += randf_range(-PI / 4, PI / 4)
	fruit.rotation = direction
	var velocity = Vector2(randf_range(100.0, 200.0) + score, 0.0)
	fruit.init(add_score, end, velocity.rotated(direction))
	add_child(fruit)


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()
