extends AnimatedSprite2D

@export var is_lit :bool = true

func _ready():
	if is_lit:
		play("lit")
	else:
		play("unlit")
