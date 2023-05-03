extends Unit
class_name PlayerUnit

@onready var selection_visual :Sprite2D = get_node("SelectedSprite")
@onready var heal_target_visual :Sprite2D = get_node("HealSprite")

# enable/disable the selection visual
func toggle_selection_visual(toggle):
	selection_visual.visible = toggle

func toggle_heal_target_visual(toggle):
	heal_target_visual.visible = toggle
