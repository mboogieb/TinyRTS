extends Unit
class_name EnemyUnit

@onready var game_manager = get_node("/root/Main")

@export var detect_range :float = 100
@export var attack_range :float = 20
@export var attack_speed :float = 0.6
@export var damage :int = 20

func _ready():
	health = max_health

func _process(delta):
	if target == null:
		for player in game_manager.players:
			if player == null:
				continue
			
			var distance = global_position.distance_to(player.global_position)
			if distance <= detect_range:
				set_target(player)
				
	attack_check()


func attack_check():
	if target != null:
		var dist = global_position.distance_to(target.global_position)
		if dist <= attack_range:
			agent.target_position = global_position
			try_attack_target()
		else:
			agent.target_position = target.global_position
			
func try_attack_target():
	var curr_time = Time.get_unix_time_from_system()
	if curr_time - last_attack_time > attack_speed:
		if !target.is_friendly(self):
			target.take_damage(damage)
			last_attack_time = curr_time
