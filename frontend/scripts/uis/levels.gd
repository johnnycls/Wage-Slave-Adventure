extends VBoxContainer

var home = preload("res://scripts/uis/home.tscn")
var level = preload("res://scripts/uis/level.tscn")
var story_scene = preload("res://scripts/stories/story.tscn")
var work_scene = preload("res://scripts/work/work.tscn")
var set_money_ui = preload("res://scripts/slash/set_money_ui.tscn")
var buy_scene = preload("res://scripts/dice/buy.tscn")
var nothing_scene = preload("res://scripts/nothing/nothing.tscn")

func on_scene_pressed(scene, key):
	var game = scene.instantiate()
	game.init(key)
	Global.main_scene.add_child(game)
	
func on_ui_pressed(scene, name):
	var ui = scene.instantiate()
	Hud.change_hud(ui, name)

var levels =  [
	[
		{"label": tr("CHAPTER_0"), "on_pressed": func(): on_scene_pressed(story_scene, 0), "key": 0, "condition": tr("UNLOCK_0")},
		{"label": tr("LEVEL1_TITLE"), "on_pressed": func(): on_ui_pressed(work_scene, Global.UI_NAMES.WORK), "key": 1, "condition": tr("UNLOCK_1")},
	],
	[
		{"label": tr("CHAPTER_1"), "on_pressed": func(): on_scene_pressed(story_scene, 100), "key": 100, "condition": tr("UNLOCK_100")},
		{"label": tr("LEVEL101_TITLE"), "on_pressed": func(): on_ui_pressed(set_money_ui, Global.UI_NAMES.SLASH_SET_MONEY), "key": 101, "condition": tr("UNLOCK_101")},
	],
	[
		{"label": tr("CHAPTER_2"), "on_pressed": func(): on_scene_pressed(story_scene, 200), "key": 200, "condition": tr("UNLOCK_200")},
		{"label": tr("LEVEL201_TITLE"), "on_pressed": func(): on_ui_pressed(buy_scene, Global.UI_NAMES.DICE), "key": 201, "condition": tr("UNLOCK_201")},
	],
	#[
		#{"label": tr("CHAPTER_3"), "on_pressed": func(): on_scene_pressed(story_scene, 300), "key": 300, "condition": tr("UNLOCK_300")},
		#{"label": tr("LEVEL301_TITLE"), "on_pressed": func(): on_ui_pressed(nothing_scene, Global.UI_NAMES.NOTHING), "key": 201, "condition": tr("UNLOCK_201")},
	#],
]

func _ready():
	for l_data in levels:
		var l = level.instantiate()
		l.init(l_data)
		$"ScrollContainer/VBoxContainer".add_child(l)
	if Global.progress == 300:
		var btn = Button.new() 
		btn.text = tr("COMING_SOON")
		$"ScrollContainer/VBoxContainer".add_child(btn)

func _on_button_pressed():
	Hud.change_hud(home.instantiate(), Global.UI_NAMES.HOME)
