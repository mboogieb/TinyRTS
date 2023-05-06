extends CharacterBody2D
class_name ResourceUnit

@export var min_start_resources :int = 10
@export var max_start_resources :int = 100
@export var resource_type :Constants.ResourceType = Constants.ResourceType.WOOD
@export var unit_team :Constants.UnitTeam
@export var resource_textures :Array[Texture2D]

var sprite :Sprite2D
var resource_bar :ProgressBar
var start_resources :int
var current_resources :int

func _ready():
	sprite = $Sprite2D
	resource_bar = $ProgressBar
	sprite.set_texture(resource_textures[resource_type])
	start_resources = randi_range(min_start_resources, max_start_resources)
	current_resources = start_resources
	resource_bar.set_max(float(start_resources))
	resource_bar.value = float(current_resources)

func _process(delta):
	if current_resources <= 0:
		queue_free()
	elif current_resources < start_resources:
		resource_bar.visible = true

func try_give_resources(amount):
	var amount_to_give = 0
	if amount <= current_resources:
		amount_to_give = amount
	else:
		amount_to_give = current_resources
	flash_sprite()
	return construct_bundle(amount_to_give)

func construct_bundle(amount):
	var resource_bundle = ResourceBundle.new()
	resource_bundle.type = self.resource_type
	resource_bundle.amount = amount
	current_resources -= amount
	resource_bar.value = float(current_resources)
	return resource_bundle

func flash_sprite():
	sprite.modulate = Color.GREEN
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
