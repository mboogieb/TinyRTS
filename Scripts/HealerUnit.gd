extends Unit
class_name HealerUnit

@export var heal_amount :int = 10
@export var heal_range :float = 80
@export var heal_speed :float = 1.5

var last_heal_time :float

func _ready():
	await get_tree().create_timer(2).timeout
	last_heal_time = Time.get_unix_time_from_system()

func _process(delta):
	heal_check()
	health_check()

func heal_check():
	if target != null:
		var dist = global_position.distance_to(target.global_position)
		if dist <= heal_range:
			agent.target_position = global_position
			if target.health <= target.max_health:
				try_heal_target()
			else:
#				target.toggle_heal_target_visual(false)
				unset_target()
		else:
			agent.target_position = target.global_position
			
func try_heal_target():
	var curr_time = Time.get_unix_time_from_system()
	if curr_time - last_heal_time >= heal_speed:
		if target.is_friendly(self):
			target.toggle_heal_target_visual(true)
			if target.needs_healing():
				target.heal_damage(heal_amount)
				last_heal_time = curr_time
