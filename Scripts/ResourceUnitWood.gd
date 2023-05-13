extends ResourceUnit
class_name ResourceUnitWood

func _process(delta):
	if current_resources <= 0:
		sprite.frame = 14
		remove_child(get_node("CollisionShape2D"))
		remove_child(resource_bar)
		enabled = false
	elif current_resources < start_resources:
		resource_bar.visible = true
