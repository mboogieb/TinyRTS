extends Unit
class_name GathererUnit

# How many resource bundles we can carry
@export var resource_capacity :int = 5
# How many resources per bundle we can fetch
@export var resource_per_fetch :int = 2
# How close to a resource node we need to be in order to gather
@export var gather_range :int = 20
# How often we can get a resource bundle from a node
@export var gather_speed :float = 2.0
# The dropoff location object
@export var resource_cache :CharacterBody2D

# Logical state
var unit_state :Constants.GatherState
# Resources unit is carrying
var current_resources :Array[ResourceBundle]
# Gathering timer
var last_gather_time
# The resource node we'll report to in GATHER mode until a different node is selected
var curr_resource_target

func _ready():
	last_gather_time = Time.get_unix_time_from_system()
	unit_state = Constants.GatherState.IDLE
	health = max_health

func _process(delta):
	match(unit_state):
		
		# If we have a valid target 
		# - and it is a resource node
		#   - switch to GATHER mode
		# - and it is a resource dropoff
		#   - and unit is carrying resources to deliver
		#     - switch to DELIVER mode
		# - and it is neither of the above
		#   - stay in IDLE mode
		Constants.GatherState.IDLE:
			if target != null:
				if target.name.begins_with("ResourceUnit"):
					curr_resource_target = target
					unit_state = Constants.GatherState.GATHER
				elif target.name == "ResourceCache" and current_resources.size() > 0:
					unit_state = Constants.GatherState.DELIVER
		
		# If our target is a valid unit
		# - but we are at capacity
		#   - switch to DELIVER mode
		# - or we selected the cache manually
		#   - switch to DELIVER mode
		# - Otherwise remain in GATHER mode and keep fetching
		# Otherwise if our target is invalid
		# - because the node is depleted
		#   - switch to DELIVER mode
		# - because we clicked the ground
		#   - switch to IDLE mode
		Constants.GatherState.GATHER:
			if target != null:
				if current_resources.size() >= resource_capacity:
					unit_state = Constants.GatherState.DELIVER
				elif target.name == "ResourceCache" and current_resources.size() > 0:
					unit_state = Constants.GatherState.DELIVER
				else:
					gather_check()
			else:
				var ref = weakref(curr_resource_target)
				if (!ref.get_ref()):
					target = resource_cache
					unit_state = Constants.GatherState.DELIVER
				else:
					curr_resource_target = null
					unit_state = Constants.GatherState.IDLE
		
		# If we are not carrying resources
		# - and the resource unit we were working on is depleted
		#   - switch to IDLE mode
		# Otherwise 
		# - If we selected a ground location
		#   - clear the resource node
		#   - switch to IDLE mode
		# - Otherwise 
		#   - stay in DELIVER mode
		#   - switch target back to the resource cache
		#   - try to deliver
		Constants.GatherState.DELIVER:
			if current_resources.is_empty():
				if curr_resource_target == null:
					unset_target()
					unit_state = Constants.GatherState.IDLE
				else:
					target = curr_resource_target
					unit_state = Constants.GatherState.GATHER
			else:
				if target == null:
					curr_resource_target = null
					unit_state = Constants.GatherState.IDLE
				else:
					target = resource_cache
					deliver_check()
				
		# Default: switch to IDLE mode
		_:
			unit_state = Constants.GatherState.IDLE

# If we targeted a resource node
# - set it as the current node
# - If we're within gathering range
#   - try to gather
# - Othewise, move closer
func gather_check():
	if target != null && target.name.begins_with("ResourceUnit"):
		curr_resource_target = target
		var dist = global_position.distance_to(target.global_position)
		if dist <= gather_range:
			print("within range")
			agent.target_position = global_position
			try_gather_resources()
		else:
			agent.target_position = target.global_position

# Collect a resource bundle from the resource node when gather timer reaches gather speed
func try_gather_resources():
	var curr_time = Time.get_unix_time_from_system()
	if curr_time - last_gather_time >= gather_speed:
		var new_resources :ResourceBundle = target.try_give_resources(resource_per_fetch)
		if new_resources != null:
			current_resources.append(new_resources)
			last_gather_time = curr_time
		else:
			curr_resource_target = null
			target = resource_cache
			unit_state = Constants.GatherState.DELIVER

# If we targeted the resource cache
# - and we're within gathering range
#   - try to deliver
# - otherwise, move closer
func deliver_check():
	if target != null && target.name == "ResourceCache":
		var dist = global_position.distance_to(resource_cache.global_position)
		if dist <= gather_range:
			agent.target_position = global_position
			try_deliver_resources()
		else:
			agent.target_position = resource_cache.global_position

# Deliver a resource bundle to the cache when the gather timer reaches gather speed
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
