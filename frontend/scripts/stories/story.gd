extends Node3D

var story_ui = preload("res://scripts/stories/ui.tscn").instantiate()
var levels_ui = preload("res://scripts/uis/levels.tscn")
var home_ui = preload("res://scripts/uis/home.tscn")

var stories = { 
	0: range(5).map(func(i): return {"dialog": tr("STORY_0_" + str(i))}),
	100: range(39).map(func(i): return {"dialog": tr("STORY_100_" + str(i))}), 
	200: range(17).map(func(i): return {"dialog": tr("STORY_200_" + str(i))}),
	300: range(20).map(func(i): return {"dialog": tr("STORY_300_" + str(i))}),
}

var story
var cur = 0
var level

func end():
	Hud.change_hud(levels_ui.instantiate(), Global.UI_NAMES.LEVELS)
	queue_free()

func init(key):
	$error_dialog.hide()
	story_ui.init(end)
	level = key
	story = stories[level]
	cur = 0
	story_ui.change_text(story[cur].dialog)
	Hud.change_hud(story_ui, Global.UI_NAMES.STORY)
	
	if (level == Global.progress):
		Global.progress = Global.UNLOCK[level]
		Global.save_state()
		Global.update_unlock_level()

func next(): 
	cur += 1
	if (cur >= story.size()):
		end()
	else:
		story_ui.change_text(story[cur].dialog)
	
func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		next()
