extends Sprite2D

@export var spawn_speed = 10
@export var min_spawn_spread = 30
@export var max_spawn_spread = 50
@export var team_unit = Constants.UnitTeam.ENEMY
var enemy_unit = load("res://Scenes/EnemyUnit.tscn")
var player_unit = load("res://Scenes/SoldierUnit.tscn")
var spawn_sign = [-1, 1]

var last_spawn
var gm

func _ready():
	gm = get_node("/root/Main")
	modulate = Game.spawn_color[team_unit]
	last_spawn = Time.get_unix_time_from_system()
	
func _process(delta):
	spawn_check()

func spawn_check():
	var curr_time = Time.get_unix_time_from_system()
	if curr_time - last_spawn >= spawn_speed:
		try_spawn()
		last_spawn = curr_time
		
func try_spawn():
	var x_var = randi_range(min_spawn_spread, max_spawn_spread) * spawn_sign[randi() % spawn_sign.size()]
	var y_var = randi_range(min_spawn_spread, max_spawn_spread) * spawn_sign[randi() % spawn_sign.size()]
	var new_unit = null
	if team_unit == Game.UnitTeam.PLAYER:
		new_unit = player_unit.instantiate()
		gm.players.append(new_unit)
	elif team_unit == Game.UnitTeam.ENEMY:
		new_unit = enemy_unit.instantiate()
		gm.enemies.append(new_unit)
	new_unit.position = global_position
	gm.get_node("Units").add_child(new_unit)
	new_unit.move_to_location(Vector2(new_unit.global_position.x + x_var, new_unit.global_position.y + y_var))
