extends CharacterBody2D
class_name Unit

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var selection_visual :Sprite2D = get_node("SelectedSprite")
@onready var heal_target_visual :Sprite2D = get_node("HealSprite")

@export var max_health :int = 100
@export var move_speed :float = 50
@export var is_player :bool
@export var unit_team :Constants.UnitTeam

var gm
var last_attack_time :float
var target :CharacterBody2D
var health_bar :ProgressBar
var sprite :Sprite2D
var health :int = 100

func _ready():
	sprite = $Sprite
	health_bar = $ProgressBar
	health = max_health
	health_check()

func _process(delta):
#	attack_check()
	health_check()

func _physics_process(delta):
	if agent == null:
		return
	if agent.is_navigation_finished():
		return
		
	var direction = global_position.direction_to(agent.get_next_path_position())
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
	if health_bar == null:
		return
		
	health_bar.set_max(float(max_health))
	health_bar.value = float(health)
	if health >= max_health:
		health_bar.modulate = Color.GREEN
	else:
		health_bar.modulate = Color.RED

func needs_healing():
	return health < max_health

func take_damage(damage_amount):
	health -= damage_amount
	if health <= 0:
		queue_free()
	health_check()

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
	heal_target_visual.visible = toggle
