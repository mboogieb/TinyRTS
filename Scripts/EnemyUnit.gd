extends SoldierUnit
class_name EnemyUnit

@export var detect_range :float = 100
@onready var game_manager = get_node("/root/Main")

func _ready():
	health = max_health

func _process(delta):
	if target == null:
		for player in game_manager.players:
			if player == null:
				continue
			
			var distance = global_position.distance_to(player.global_position)
			if distance <= detect_range:
				set_target(player)
				
	attack_check()
