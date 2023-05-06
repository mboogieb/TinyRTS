extends Sprite2D

# Load and fade (includes queue_free)
func _ready():
	$AnimationPlayer.play("fade")
