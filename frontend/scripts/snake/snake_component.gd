extends Area2D

var component = 0

func init(_component, end):
	component = _component
	area_entered.connect(func(area): _on_area_enter(area, end))
		
func set_component(_component):
	component = _component
		
func _on_area_enter(area, end):
	if component==0 && area.is_in_group("snake_components") && area.component==2:
		end.call()
