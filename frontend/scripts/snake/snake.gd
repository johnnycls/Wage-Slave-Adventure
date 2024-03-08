extends Node2D

var component_scene = preload("res://scripts/snake/snake_component.tscn")

const NECK_LEN = 20
const INIT_TAIL_LEN = 20
const COMPONENT_WIDTH = 2
const LEN_INC = 5

var components = []
var target_pos = Vector2(100000,0)
var _is_playing = false
var score = 0
var should_move = false
var end_game_func
var scene_size

func add_component(_component, pos):
	var component = component_scene.instantiate()
	component.init(_component, end_game_func)
	component.position = pos
	components.append(component)
	call_deferred("add_child", component)
		
func init(end, _scene_size):
	scene_size = _scene_size
	end_game_func = func():
		end.call()
		_is_playing = false
		should_move = false
		
	add_component(0, Vector2(0.5*COMPONENT_WIDTH, 0))
	for i in range(NECK_LEN):
		add_component(1, Vector2((0.5-i-1)*COMPONENT_WIDTH, 0))
	for i in range(INIT_TAIL_LEN):
		add_component(2, Vector2((0.5-i-NECK_LEN-1)*COMPONENT_WIDTH, 0))

func _physics_process(delta):
	if _is_playing and should_move:
		_move()

func start(_score):
	score = _score
	for i in range(score*LEN_INC):
		add_component(2, Vector2((0.5-i-NECK_LEN-1-INIT_TAIL_LEN)*COMPONENT_WIDTH, 0))
		
	_is_playing = true
	
func get_score():
	score += 1
	for i in range(LEN_INC):
		add_component(2, components[-2].position.direction_to(components[-1].position) + components[-1].position)
	
func set_target_pos(pos):
	target_pos = pos
	should_move = true
	
func stop():
	should_move = false

func _move():
	if components[0].position.distance_to(target_pos)>score/5+2:
		var direction = components[0].position.direction_to(target_pos)
		for i in range(score/10 + 1):
			components[NECK_LEN].set_component(2)
			components[0].set_component(1)
			var original_tail = components.pop_back()
			original_tail.position = components[0].position + direction*COMPONENT_WIDTH
			original_tail.look_at(target_pos)
			original_tail.set_component(0)
			components.push_front(original_tail)
		if components[0].position.x < -scene_size.x/2 or components[0].position.x > scene_size.x/2 or components[0].position.y < -scene_size.y/2 or components[0].position.y > scene_size.y/2:
			end_game_func.call()
