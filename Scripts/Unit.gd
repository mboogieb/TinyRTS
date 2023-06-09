extends CharacterBody2D
class_name Unit

@onready var agent :NavigationAgent2D = $NavigationAgent2D
@onready var health_bar :ProgressBar = get_node("ProgressBar")
@onready var selection_visual :Sprite2D = get_node("SelectedSprite")
@onready var heal_target_visual :Sprite2D = get_node("HealSprite")
@onready var sprite :Sprite2D = get_node("Sprite")

@export var max_health :int = 100
@export var move_speed :float = 20
@export var is_player :bool = true
@export var unit_team :Constants.UnitTeam = Constants.UnitTeam.PLAYER

var gm
var last_attack_time :float
var target :CharacterBody2D
var health :int

func _ready():
	health = max_health
	health_check()

func _physics_process(delta):
	if agent == null:
		return
	if agent.is_navigation_finished():
		return
		
	var direction = global_position.direction_to(agent.get_next_path_position())
#	print("Unit dir: ", direction, "[", round(direction.x), ",", round(direction.y), "]")
	
	# TODO: Direction scale from -1 <= x <= 1, -1 <=
	# Full north: 0, -1
	# Full south: 0, 1
	# Full East: 1, 0
	# Full West: -1, 0
	var angle = atan2(snappedf(direction.y, 0.5), snappedf(direction.x, 0.5))
	
	var prelim = (angle * 2 / PI)
	var cardinal_direction = (snappedi(prelim, 1) % 4)
#	print("Compass: ", cardinal_direction)
	velocity = direction * move_speed
	move_and_slide()

func move_to_location(location):
	unset_target()
	agent.target_position = location
	

func set_target(new_target):
	target = new_target
	
func unset_target():
	target = null

func is_friendly(source):
	return self.unit_team == source.unit_team

func health_check():
	health_bar.set_max(max_health)
	health_bar.set_value(health)

	if health >= max_health * .75:
		health_bar.modulate = Color.GREEN
	elif health >= max_health * .5:
		health_bar.modulate = Color.YELLOW
	elif health >= max_health * .25:
		health_bar.modulate = Color.ORANGE
	else:
		health_bar.modulate = Color.RED

func needs_healing():
	return health < max_health

func take_damage(damage_amount):
	health -= damage_amount
	health_check()
	if health <= 0:
		queue_free()
		return
		
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
	
func heal_damage(heal_amount):
	health += heal_amount
	if health >= max_health:
		health = max_health
	health_check()
	
	sprite.modulate = Color.GREEN
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
	
# enable/disable the selection visual
func toggle_selection_visual(toggle):
	selection_visual.visible = toggle

func toggle_heal_target_visual(toggle):
	#heal_target_visual.visible = toggle
	pass
