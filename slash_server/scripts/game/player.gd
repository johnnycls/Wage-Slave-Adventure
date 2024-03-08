extends CharacterBody3D


var player_id
var user_id 
var display_name 
var skin 
var stats
var HP 
var full_hp
var money: int
var sent_end_data := false
var last_hit_time = Time.get_unix_time_from_system() 
var one_sec_passed = false

var move_speed: float = 3.0
var start_pos: Vector2 = Vector2(0, 0)
var v: Vector3 = Vector3(0, 0, 0)
var r: Vector3 = Vector3(0, 0, 0)

func init(init_data):
	Global.time_event(1.0, func():
		one_sec_passed = true
	)
	player_id = init_data.player_id 
	user_id = init_data.user_id 
	skin = init_data.skin
	stats = init_data.stats
	full_hp = init_data.HP
	HP = init_data.HP 
	move_speed = init_data.stats.speed * 3.0
	money = init_data.money * 0.9
	position = init_data.pos 
	rotation = init_data.rot 
	$cleaver.init(init_data.cleaver.scale, init_data.stats.attack)

func _physics_process(delta):
	if (one_sec_passed):
		velocity = v
		move_and_slide()
	else:
		velocity = Vector3(0,0,0)


func move(event):
	if HP>0: 
		match event.type:
			0:
				start_pos = event.position
			1: 
				v = Vector3(0, 0, 0)
			2:
				var direction = Vector3(start_pos.x-event.position.x, 0, start_pos.y-event.position.y).rotated(Vector3.UP, rotation.y).normalized()
				v = direction * move_speed
			3:
				rotation = event.rotation


func slash():
	if HP>0:
		$cleaver.slash()


func hit(_attack, by):
	var time_diff = Time.get_unix_time_from_system() - last_hit_time
	if (by!=self && time_diff>0.5):
		last_hit_time = Time.get_unix_time_from_system()
		var new_hp = max(0, HP-_attack)
		var change = HP - new_hp 
		
		var money_loss = money*change/HP if HP!=0 else money
		HP = new_hp
		money -= money_loss
		if by.is_in_group("players"):
			by.money += money_loss
		
		if HP <= 0:
			$"../../game".dead(self)
