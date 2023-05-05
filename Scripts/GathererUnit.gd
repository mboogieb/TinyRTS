extends Unit
class_name GathererUnit

@export var resource_capacity :int = 5
@export var resource_per_fetch :int = 2
@export var gather_range :int = 20
@export var gather_speed :float = 2.0
@export var resource_cache :CharacterBody2D

var unit_state :Constants.GatherState
var current_resources :Array[ResourceBundle]
var resource_node :ResourceUnit
var last_gather_time
var curr_resource_target

func _ready():
	last_gather_time = Time.get_unix_time_from_system()
	unit_state = Constants.GatherState.IDLE

func _process(delta):
	health_check()
	match(unit_state):
		Constants.GatherState.IDLE:
#			print("IDLE")
			if target != null:
				if target.name.begins_with("ResourceUnit"):
					unit_state = Constants.GatherState.GATHER
				if target.name == "ResourceCache":
					unit_state = Constants.GatherState.DELIVER
		Constants.GatherState.GATHER:
#			print("GATHER")
			if target != null:
				if current_resources.size() < resource_capacity:
					gather_check()
				else:
#					print("Gatherer is overburdened")
					unit_state = Constants.GatherState.DELIVER
			elif target == null && !current_resources.is_empty():
				unit_state = Constants.GatherState.DELIVER
			else:
				unit_state = Constants.GatherState.IDLE
		Constants.GatherState.DELIVER:
#			print("DELIVER")
			if current_resources.is_empty():
				if curr_resource_target == null:
					unset_target()
					unit_state = Constants.GatherState.IDLE
				else:
					target = curr_resource_target
					unit_state = Constants.GatherState.GATHER
			else:
				target = resource_cache
				deliver_check()
		_:
#			print("NO STATE")
			unit_state = Constants.GatherState.IDLE

func gather_check():
	if target != null && target.name.begins_with("ResourceUnit"):
		curr_resource_target = target
		var dist = global_position.distance_to(target.global_position)
		if dist <= gather_range:
			agent.target_position = global_position
			try_gather_resources()
		else:
			agent.target_position = target.global_position

func try_gather_resources():
	var curr_time = Time.get_unix_time_from_system()
	if curr_time - last_gather_time >= gather_speed:
		var new_resources :ResourceBundle = target.try_give_resources(resource_per_fetch)
		current_resources.append(new_resources)
		last_gather_time = curr_time

func deliver_check():
	if target != null && target.name == "ResourceCache":
		var dist = global_position.distance_to(resource_cache.global_position)
		if dist <= gather_range:
			agent.target_position = global_position
			try_deliver_resources()
		else:
			agent.target_position = resource_cache.global_position
		
func try_deliver_resources():
	var curr_time = Time.get_unix_time_from_system()
	if current_resources.is_empty():
		unit_state = Constants.GatherState.IDLE
	else:
		if curr_time - last_gather_time >= gather_speed:
			var bundle = current_resources[0]
			target.store_resources(bundle)
			current_resources.erase(bundle)
			last_gather_time = curr_time
