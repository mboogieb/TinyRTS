extends CanvasLayer

@export var game_manager :Node2D
@export var resource_manager :CharacterBody2D

const wood_prefix = "Wood: "
const stone_prefix = "Stone: "
const unit_prefix = "Units: "

var wood_label :Label
var stone_label :Label
var unit_label :Label

# Called when the node enters the scene tree for the first time.
func _ready():
	# Identify the labels we plan to update
	wood_label = get_node("MarginContainer/HBoxContainer/WoodLabel")
	stone_label = get_node("MarginContainer/HBoxContainer/StoneLabel")
	unit_label = get_node("MarginContainer/HBoxContainer/UnitLabel")
	
	# To receive the unit metrics from the level
	var levels = get_tree().get_nodes_in_group("Levels")
	if levels.size() > 0:
		levels[0].units_changed.connect(_on_units_changed)
		
	# To receive the resource metrics from all live resource caches
	var caches = get_tree().get_nodes_in_group("Caches")
	if caches.size() > 0:
		caches[0].resources_changed.connect(_on_resources_changed)

# Set the appropriate resource label when we gain or spend resources
func _on_resources_changed(resource_type, total_amount):
	match(resource_type):
		Constants.ResourceType.WOOD:
			wood_label.text = "%s %s" % [wood_prefix, str(total_amount)]
		Constants.ResourceType.STONE:
			stone_label.text = "%s %s" % [stone_prefix, str(total_amount)]

# Set the player unit labels with current count and current max
func _on_units_changed(current_units, allowed_units):
	unit_label.text = "%s %s/%s" % [unit_prefix, current_units, allowed_units]
