extends CanvasGroup

@export var game_manager :Node2D
@export var resource_manager :CharacterBody2D

const wood_prefix = "Wood: "
const stone_prefix = "Stone: "
const unit_prefix = "Units: "

var wood_label :Label
var stone_label :Label
var unit_label :Label

var wood_amount :int = 0
var stone_amount :int = 0
var unit_amount :int = 0

var update_speed = 1
var last_update = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	wood_label = get_node("HBoxContainer/WoodLabel")
	stone_label = get_node("HBoxContainer/StoneLabel")
	unit_label = get_node("HBoxContainer/UnitLabel")
	last_update = Time.get_unix_time_from_system()
	
func _process(delta):
	var curr_time = Time.get_unix_time_from_system()
	if curr_time - last_update >= update_speed:
		update_wood()
		update_stone()
		update_units()
		last_update = curr_time
		
func update_wood():
	var total_amount = resource_manager.get_resource_count(Constants.ResourceType.WOOD)
	wood_label.text = "%s %s" % [wood_prefix, str(total_amount)]

func update_stone():
	var total_amount = resource_manager.get_resource_count(Constants.ResourceType.STONE)
	stone_label.text = "%s %s" % [stone_prefix, total_amount]
	
func update_units():
	var total_amount = game_manager.players.size()
	unit_label.text = "%s %s" % [unit_prefix, total_amount]
