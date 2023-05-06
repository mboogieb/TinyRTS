extends Node2D

# Visual feedback on the ground where the selected unit is moving to
var selected_location = load("res://Scenes/SelectedLocation.tscn")
# Currently selected unit
var selected_unit :CharacterBody2D
# Collection of player units
var players :Array[CharacterBody2D]
# Collection of enemy units
var enemies :Array[CharacterBody2D]
# Scene camera
var camera :Camera2D
var curr_camera_zoom :float = 2.5 #3.75
# Collection of player resources
var player_resources = {
	Constants.ResourceType.WOOD: 0, 
	Constants.ResourceType.STONE: 0
}

func _ready():
	camera = get_viewport().get_camera_2d()
	camera.set_zoom(Vector2(curr_camera_zoom, curr_camera_zoom))

func _process(delta):
	if players.is_empty() and enemies.is_empty():
		fetch_all_units()

# Tally up the units if we haven't already done so
func fetch_all_units():
	var unit_root = get_node("/root/Main/Units")
	for child in unit_root.get_children():
		if child.is_in_group("Unit"):
			if child.unit_team == Constants.UnitTeam.PLAYER:
				players.append(child)
			if child.unit_team == Constants.UnitTeam.ENEMY:
				enemies.append(child)

# Select target with LMB, Attack/Heal/Move/etc with RMB
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			try_select_unit()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			try_command_unit()

func get_selected_unit():
	# Get the space state
	var space = get_world_2d().direct_space_state
	# Create a space state query
	var query = PhysicsPointQueryParameters2D.new()
	# Use the mouse position for the space query
	query.position = get_global_mouse_position()
	# Check if anything is under the mouse
	var intersection = space.intersect_point(query, 1)
	
	# If the space query returned results, return the collider of the found object
	if !intersection.is_empty():
		return intersection[0].collider
		
	# Otherwise return null
	return null
	
# Select unit with left click
func try_select_unit():
	var unit = get_selected_unit()
	if unit != null and unit.unit_team != Constants.UnitTeam.ENEMY:
		select_unit(unit)
	else:
		unselect_unit()

func select_unit(unit):
	unselect_unit()
	selected_unit = unit
	selected_unit.toggle_selection_visual(true)
	
func unselect_unit():
	if selected_unit != null:
		selected_unit.toggle_selection_visual(false)
		
	selected_unit = null
	
func try_command_unit():
	# Don't do anything if a unit isn't selected
	if selected_unit == null:
		return
	
	var target = get_selected_unit()
	# If we right click on a unit/resource/etc, set that as our target
	if target != null:
		selected_unit.set_target(target)
	# Otherwise, just flash the selector at the RMB spot and move there
	else:
		var mouse_position :Vector2 = get_global_mouse_position()
		var loc = selected_location.instantiate()
		loc.position = mouse_position
		add_child(loc)
		selected_unit.move_to_location(mouse_position)
