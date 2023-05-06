extends CharacterBody2D
class_name ResourceUnit

@export var min_start_resources :int = 100
@export var max_start_resources :int = 1000
@export var resource_type :Constants.ResourceType
@export var unit_team :Constants.UnitTeam
@export var resource_textures :Array[Texture2D]

var sprite :Sprite2D
var start_resources :int
var current_resources :int

func _ready():
	sprite = $Sprite2D
	sprite.texture = resource_textures[resource_type]
	start_resources = randi_range(min_start_resources, max_start_resources)
	current_resources = start_resources

func _process(delta):
	if current_resources <= 0:
		queue_free()

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
	return resource_bundle

func flash_sprite():
	sprite.modulate = Color.GREEN
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
