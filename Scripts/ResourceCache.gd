extends Node
class_name ResourceCache

signal resources_changed

var resources :Dictionary
var sprite :Sprite2D

func _ready():
	resources = {}
	sprite = $Sprite2D
	for value in Constants.ResourceType.values():
		resources[value] = 0

func _input(event):
	if Input.is_action_just_pressed("DEBUG_GAIN_WOOD"):
		var bundle :ResourceBundle = ResourceBundle.new()
		bundle.type = Constants.ResourceType.WOOD
		bundle.amount = 100
		store_resources(bundle)
	if Input.is_action_just_pressed("DEBUG_GAIN_STONE"):
		var bundle :ResourceBundle = ResourceBundle.new()
		bundle.type = Constants.ResourceType.STONE
		bundle.amount = 100
		store_resources(bundle)
# Print the entire cache contents
func print_cache():
	print("Cache: ", resources)

# Get the current count of a given resource
func get_resource_count(resource_type):
	if resources[resource_type] == null:
		return 0
	else:
		return resources[resource_type]

# Store resource bundles into the team resource cache
func store_resources(resource_bundle :ResourceBundle):
	resources[resource_bundle.type] += resource_bundle.amount
	sprite.modulate = Color.GREEN
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
	resources_changed.emit(resource_bundle.type, resources[resource_bundle.type])
#	emit_signal("resource_changed", resource_bundle.type, resources[resource_bundle.type])

# Tell caller if it can have the amount of ResourceType it is asking for
func take_resources(resource_type :Constants.ResourceType, amount :int):
	var available = resources[resource_type]
	if available >= amount:
		resources[resource_type] -= amount
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE
		resources_changed.emit(resource_type, resources[resource_type])
