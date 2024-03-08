extends Node3D
var static_box = preload("res://scripts/components/static_box.tscn")

func create_map(ground_data, buildings):
	var ground = static_box.instantiate()
	ground.init(ground_data.pos, ground_data.scale)
	add_child(ground)
	
	for building_data in buildings:
		var building = static_box.instantiate()
		building.init(building_data.pos, building_data.scale)
		add_child((building))
