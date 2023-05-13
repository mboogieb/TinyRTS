extends CharacterBody2D
class_name ResourceUnit

@onready var selection_visual :Sprite2D = get_node("SelectedSprite")

# lowest possible amount of resources to start with
@export var min_start_resources :int = 10
# highest possible amount of resources to start with
@export var max_start_resources :int = 100

@export var enabled :bool = true
# Enum type of resource
@export var resource_type :Constants.ResourceType = Constants.ResourceType.WOOD
# Sprite sheet
@export var resource_texture :Texture2D
# spritesheet metrics: x = columns, y = rows
@export var sprite_frames :Vector2i
# Number of unused live frames in texture spritesheet
@export var max_frame_offset :int = 0


var resource_bar :ProgressBar
var sprite :Sprite2D
var start_resources :int
var current_resources :int

func _ready():
	sprite = get_node("Sprite2D")
	resource_bar = $ProgressBar
	sprite.set_texture(resource_texture)
	start_resources = randi_range(min_start_resources, max_start_resources)
	current_resources = start_resources
	resource_bar.set_max(float(start_resources))
	resource_bar.value = float(current_resources)
	sprite.hframes = sprite_frames.x
	sprite.vframes = sprite_frames.y
	set_sprite()

# Try to give what is asked.
# If there isn't that much, give what's left
func try_give_resources(amount):
	if enabled:
		var amount_to_give = 0
		if amount <= current_resources:
			amount_to_give = amount
		else:
			amount_to_give = current_resources
		flash_sprite()
		return construct_bundle(amount_to_give)

# Put together a resource bundle of this type paired with the amount
func construct_bundle(amount):
	var resource_bundle = ResourceBundle.new()
	resource_bundle.type = self.resource_type
	resource_bundle.amount = amount
	current_resources -= amount
	resource_bar.value = float(current_resources)
	return resource_bundle

# Select a random sprite from the given texture
func set_sprite():
	var max_index = (sprite.hframes * sprite.vframes) - (max_frame_offset + 1)
	sprite.frame = randi_range(0, max_index)

# Visual feedback that resource unit is being actively harvested
func flash_sprite():
	sprite.modulate = Color.GREEN
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE

# enable/disable the selection visual
func toggle_selection_visual(toggle):
	selection_visual.visible = toggle
