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

enum GatherState {
	IDLE,
	GATHER, 
	DELIVER
}

const spawn_color = {
	UnitTeam.PLAYER: Color.BLUE,
	UnitTeam.ENEMY: Color.RED
}
