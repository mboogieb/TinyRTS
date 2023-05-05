extends Unit
class_name SoldierUnit

@export var attack_range :float = 20
@export var attack_speed :float = 0.5
@export var damage :int = 20

func _process(delta):
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
