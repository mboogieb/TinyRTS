extends Node2D

var selected_unit :CharacterBody2D
var players :Array[CharacterBody2D]
var enemies :Array[CharacterBody2D]
var camera :Camera2D
var curr_camera_zoom :float = 2.5 #3.75
var player_resources = {
	Constants.ResourceType.WOOD: 0, 
	Constants.ResourceType.STONE: 0
}
#var min_camera_zoom :float = 1
#var max_camera_zoom :float = 3
#var camera_zoom_step :float = 0.1
var debug_time :int = 5
var last_debug :float

func _ready():
	camera = get_viewport().get_camera_2d()
	camera.set_zoom(Vector2(curr_camera_zoom, curr_camera_zoom))
	last_debug = Time.get_unix_time_from_system()
	
func _process(delta):
	var curr_time = Time.get_unix_time_from_system()
	if curr_time - last_debug >= debug_time:
		print("P: ", players)
		print("E: ", enemies)
		last_debug = curr_time
	if players.is_empty() and enemies.is_empty():
		fetch_all_units()

func fetch_all_units():
	var unit_root = get_node("/root/Main/Units")
	for child in unit_root.get_children():
		if child.is_in_group("Unit"):
			if child.unit_team == Constants.UnitTeam.PLAYER:
				players.append(child)
			if child.unit_team == Constants.UnitTeam.ENEMY:
				enemies.append(child)

# Select target with LMB, Attack/Heal/Move with RMB
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			try_select_unit()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			try_command_unit()
#		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
#			try_zoom_out()
#		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
#			try_zoom_in()

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
	if selected_unit == null:
		return
	
	var target = get_selected_unit()
	if target != null:
		selected_unit.set_target(target)
	else:
#		print("Mouse: ", get_global_mouse_position())
		selected_unit.move_to_location(get_global_mouse_position())


#func try_zoom_in():
#	var next_step = curr_camera_zoom - camera_zoom_step
#	if next_step >= min_camera_zoom:
#		camera.set_zoom(Vector2(next_step, next_step))
#		curr_camera_zoom = next_step
#
#func try_zoom_out():
#	var next_step = curr_camera_zoom + camera_zoom_step
#	if next_step <= max_camera_zoom:
#		camera.set_zoom(Vector2(next_step, next_step))
#		curr_camera_zoom = next_step
