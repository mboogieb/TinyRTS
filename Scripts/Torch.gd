extends AnimatedSprite2D

# Common script used for torches, campfires

@onready var game_manager = get_node("/root/Main")

@export var is_lit :bool = true
@export var can_heal :bool = false
@export var heal_range :float = 30
@export var heal_amount :int = 5
@export var heal_speed :int = 10

var last_heal_time = 0

func _ready():
	last_heal_time = Time.get_unix_time_from_system()
	if is_lit:
		play("lit")
	else:
		play("unlit")

func set_lit_state(new_state :bool):
	is_lit = new_state
	
func _process(delta):
	try_heal_units()

# Attempt to heal all player units if this fire can heal and if the timer is done
func try_heal_units():
	var curr_time = Time.get_unix_time_from_system()
	if is_lit and curr_time - last_heal_time >= heal_speed:
		heal_nearby_units(game_manager.players)
		last_heal_time = curr_time
		
# Use shape query to heal every player within range
func heal_nearby_units(unit_set :Array[CharacterBody2D]):
	var units_to_heal = game_manager.find_units_in_circle(global_position, heal_range)
	for unit in units_to_heal:
		if unit == null:
			continue
		if unit.needs_healing():
			unit.heal_damage(heal_amount)
