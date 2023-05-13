extends ResourceUnit
class_name ResourceUnitStone

func _process(delta):
	if current_resources <= 0:
		queue_free()
	elif current_resources < start_resources:
		resource_bar.visible = true
