extends Area2D

var add_score_func
var end_func
var velocity
var started = false

func init(_add_score_func, _end_func, _velocity):
	add_score_func = _add_score_func
	end_func = _end_func
	velocity = _velocity
	started = true

func _on_area_entered(area):
	if (area.is_in_group("snake_components") && area.component==0):
		add_score_func.call()
		queue_free()
	elif (area.is_in_group("snake_components") && area.component==2):
		end_func.call()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
func _physics_process(delta):
		position += velocity * delta
