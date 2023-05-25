extends StaticBody2D
class_name SpawnBuilding

signal team_capacity_changed

@onready var health_bar :ProgressBar = get_node("HealthBar")
@onready var build_bar :ProgressBar = get_node("BuildBar")
@onready var queue_label :Label = get_node("QueueLabel")
@onready var spawn_point :Node2D = get_node("SpawnPoint")
@onready var active_sprite :Sprite2D = get_node("ActiveSprite")
@onready var construction_sprite :Sprite2D = get_node("ConstructionSprite")

@export var unit_team :Constants.UnitTeam = Constants.UnitTeam.PLAYER
@export var spawn_type :Constants.UnitType = Constants.UnitType.SOLDIER
@export var is_built :bool = false
@export var construction_cost :SummonsBundle
@export var spawn_cost :SummonsBundle
@export var max_health :int = 100
@export var spawn_speed :int = 10
@export var max_queue_size :int = 4
@export var unit_capacity_added :int = 3
# Range for spreading out spawned units that haven't been moved
@export var min_spawn_spread = 20
@export var max_spawn_spread = 40

var gm
var resource_cache
var is_spawning = false
var build_queue :Array[PackedScene] = []
var max_construction :int = 100
var curr_construction :int = 0
var health :int = 0
var spawn_timer_start = 0
var spawn_unit :PackedScene
# For adding some randomness into unit's initial position target
var spawn_sign = [-1, 1]

func _ready():
	gm = get_node("/root/Main")
	resource_cache = gm.get_node("Resources/ResourceCache")
	
	if not is_built:
		health = 0
		health_bar.set_max(max_construction)
		build_bar.set_max(max_construction)
		health_bar.set_value(curr_construction)
	else:
		health = max_health
		health_bar.set_max(max_health)
		build_bar.set_max(spawn_speed)
		health_check()
		
	curr_construction = 0
	build_bar.set_value(curr_construction)
	construction_sprite.visible = not is_built
	active_sprite.visible = is_built
	
	find_scene_to_spawn()

func _process(delta):
	if is_built:
		if not build_queue.is_empty():
			if not is_spawning:
				is_spawning = true
				spawn_timer_start = Time.get_unix_time_from_system()
			
			spawn_check()
			
	check_queue_label()
		
func _input(event):
	if Input.is_action_just_pressed("DEBUG_BUILD_ALL") and not is_built:
		advance_construction(25)
	# TODO: Delete this when construction from UI is implemented
	if Input.is_action_just_pressed("DEBUG_SPAWN_HEALER") and self.name == "Priory":
		if build_queue.size() < max_queue_size:
			build_queue.append(spawn_unit)
			check_queue_label()
	elif Input.is_action_just_pressed("DEBUG_SPAWN_SOLDIER") and self.name == "Barracks":
		if build_queue.size() < max_queue_size:
			build_queue.append(spawn_unit)
			check_queue_label()
	elif Input.is_action_just_pressed("DEBUG_SPAWN_LABORER") and self.name == "Tent":
		if build_queue.size() < max_queue_size:
			build_queue.append(spawn_unit)
			check_queue_label()

# Load the scene corresponding to the unit this building can spawn
func find_scene_to_spawn():
	if unit_team == Constants.UnitTeam.PLAYER:
		spawn_unit = load(Constants.player_unit_scenes[spawn_type])
	elif unit_team == Constants.UnitTeam.ENEMY:
		spawn_unit = load(Constants.enemy_unit_scenes[spawn_type])
		
# Attempt to spawn if our spawn timer is timed out
func spawn_check():
	var curr_time = Time.get_unix_time_from_system()
	if curr_time - spawn_timer_start >= spawn_speed:
		try_spawn()
	else:
		build_bar.set_value(curr_time - spawn_timer_start)
		
# If we have team capacity, and we have the resources to spend:
# Spawn a new unit instace and let it wander a little bit
func try_spawn():
	if gm.unit_count(unit_team) < gm.unit_limits[unit_team]:
		if resources_confirmed():
			spend_resources()
		else:
			return
		
		var x_var = randi_range(min_spawn_spread, max_spawn_spread) * spawn_sign[randi() % spawn_sign.size()]
		var y_var = randi_range(min_spawn_spread, max_spawn_spread) * spawn_sign[randi() % spawn_sign.size()]
		var new_unit = null
		
		if unit_team == Game.UnitTeam.PLAYER:
			new_unit = spawn_unit.instantiate()
			gm.register_unit(new_unit, unit_team)
			
		if spawn_type == Constants.UnitType.LABORER:
			new_unit.resource_cache = resource_cache
			
		new_unit.position = Vector2(global_position.x + spawn_point.position.x, global_position.y + spawn_point.position.y)
		gm.get_node("Units").add_child(new_unit)
		new_unit.move_to_location(Vector2(new_unit.global_position.x + x_var, new_unit.global_position.y + y_var))
		build_bar.set_value(0)
		is_spawning = false
		build_queue.remove_at(0)
		check_queue_label()

# Check that all required resources are available
func resources_confirmed():
	for bundle in spawn_cost.cost:
		if bundle.amount > resource_cache.get_resource_count(bundle.type):
			return false
	return true

# Spend all required resources to summon
func spend_resources():
	for bundle in spawn_cost.cost:
		resource_cache.take_resources(bundle.type, bundle.amount)

func health_check():
	if health >= max_health * .75:
		health_bar.modulate = Color.GREEN
	elif health >= max_health * .5:
		health_bar.modulate = Color.YELLOW
	elif health >= max_health * .25:
		health_bar.modulate = Color.ORANGE
	else:
		health_bar.modulate = Color.RED
		
	health_bar.set_max(max_health)
	health_bar.set_value(health)
	
	if is_built and health <= 0:
		destroy_building()

func needs_repair():
	return health < max_health

func take_damage(amount :int):
	health -= amount
	if health < 0:
		health = 0
		
	health_check()
	
func repair_damage(amount :int):
	health += amount
	if health > max_health:
		health = max_health
		
	health_check()

# Continue progress on the building construction
func advance_construction(amount):
	if not is_built:
		curr_construction += amount
		health_bar.set_value(curr_construction)
		build_bar.set_value(curr_construction)
		
		if curr_construction >= max_construction:
			is_built = true
			finalize_construction()

# Construction is complete - initialize everything for normal building usage
func finalize_construction():
	if is_built:
		health_bar.set_max(max_health)
		build_bar.set_max(spawn_speed)
		build_bar.set_value(0)
		construction_sprite.visible = false
		active_sprite.visible = true
	
func destroy_building():
	queue_free()

func check_queue_label():
	if build_queue.size() > 0:
		queue_label.text = str(build_queue.size())
		queue_label.visible = true
	else:
		queue_label.visible = false
