extends Unit
class_name HealerUnit

@export var heal_amount :int = 10
@export var heal_range :float = 60
@export var heal_speed :float = 3

# Enforces heal speed
var last_heal_time :float
# Tracks units within healing range
# - key: CharacterBody2D
# - value: Entry timestamp
var units_in_range :Dictionary = {}

func _ready():
	last_heal_time = Time.get_unix_time_from_system()
	health = max_health

func _process(delta):
	heal_check()

# Try heal cycle if there are units in range and heal timer is done
# - Collider area mask only includes player units
func heal_check():
	var curr_time = Time.get_unix_time_from_system()
	if not units_in_range.is_empty() and curr_time - last_heal_time >= heal_speed:
		for unit in units_in_range:
			try_heal_target(unit)
		last_heal_time = curr_time
		
# Heal friendly units that aren't at max HP
func try_heal_target(unit_to_heal):
	if unit_to_heal is Unit:
		if unit_to_heal.needs_healing():
			unit_to_heal.heal_damage(heal_amount)
		
func _on_area_2d_body_entered(body):
	if body != self:
		units_in_range[body] = Time.get_unix_time_from_system()
		
func _on_area_2d_body_exited(body):
	units_in_range.erase(body)
	
