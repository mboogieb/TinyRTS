class_name Constants

enum ResourceType {
	WOOD, 
	STONE
}

enum UnitTeam {
	PLAYER, 
	ENEMY, 
	NEUTRAL
}
enum UnitType {
	SOLDIER,
	CLERIC,
	LABORER
}

#var enemy_unit = load("res://Scenes/EnemyUnit.tscn")
#var player_unit = load("res://Scenes/SoldierUnit.tscn")

enum GatherState {
	IDLE,
	GATHER, 
	DELIVER
}

const spawn_color = {
	UnitTeam.PLAYER: Color.BLUE,
	UnitTeam.ENEMY: Color.RED
}

enum BannerColor {
	RED,
	ORANGE,
	YELLOW,
	GREEN,
	BLUE,
	PURPLE,
	BLACK,
	WHITE
}

const enemy_unit_scenes = {
	UnitType.SOLDIER: "res://Scenes/EnemyUnit.tscn"
}

const player_unit_scenes = {
	UnitType.SOLDIER: "res://Scenes/SoldierUnit.tscn",
	UnitType.CLERIC: "res://Scenes/HealerUnit.tscn",
	UnitType.LABORER: "res://Scenes/GathererUnit.tscn"
}
