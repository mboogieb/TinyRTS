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

enum BuildingType {
	TENT,
	BARRACKS,
	PRIORY
}

#var enemy_unit = load("res://Scenes/EnemyUnit.tscn")
#var player_unit = load("res://Scenes/SoldierUnit.tscn")

enum GatherState {
	IDLE,
	GATHER, 
	DELIVER,
	BUILD
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
	UnitType.LABORER: "res://Scenes/LaborerUnit.tscn"
}

const player_building_scenes = {
	BuildingType.TENT: "res://Scenes/Tent.tscn",
	BuildingType.PRIORY: "res://Scenes/Priory.tscn",
	BuildingType.BARRACKS: "res://Scenes/Barracks.tscn"
}

const player_building_pointers = {
	BuildingType.TENT: "res://Sprites/Tent_Ghost.png",
	BuildingType.BARRACKS: "res://Sprites/Barracks_Ghost.png",
	BuildingType.PRIORY: "res://Sprites/Priory_Ghost.png"
}
