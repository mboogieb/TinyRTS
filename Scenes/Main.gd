extends Node2D

@export var debug_mode :bool = false

# Visual feedback of selected unit's target
var selected_location = load("res://Scenes/SelectedLocation.tscn")
var enemy_location = load("res://Scenes/EnemyLocation.tscn")

# Currently selected units
var selected_units :Array[CharacterBody2D]
# Collection of all active player units
var players :Array[CharacterBody2D]
# Collection of all active enemy units
var enemies :Array[CharacterBody2D]
# Scene camera
var camera :Camera2D
var curr_camera_zoom :float = 3
# Collection of player resources
var player_resources = {
	Constants.ResourceType.WOOD: 0, 
	Constants.ResourceType.STONE: 0
}

# Tracks whether we are dragging a selection window area
var dragging = false
# Temporarily holds units within selection window area
var selected_tmp = []
# Start position for selection window
var drag_start = Vector2.ZERO
# End position for selection window
var drag_end = Vector2.ZERO
# Area used to query for intersecting colliders
var select_rect = RectangleShape2D.new()

# How often to print debug messages in _process()
var debug_timer = 5
var last_debug = 0

func _ready():
	camera = get_viewport().get_camera_2d()
	camera.set_zoom(Vector2(curr_camera_zoom, curr_camera_zoom))
	
	if debug_mode:
		last_debug = Time.get_unix_time_from_system()

func _process(delta):
	if players.is_empty() and enemies.is_empty():
		fetch_all_units()
	elif enemies.is_empty():
		print("VICTORY")
	elif players.is_empty():
		print("DEFEAT")
	else:
		enemies = recount_unit_registers(enemies)
		players = recount_unit_registers(players)
		selected_units = recount_unit_registers(selected_units)
		
	if debug_mode:
		var curr_time = Time.get_unix_time_from_system()
		if curr_time - last_debug >= debug_timer:
			print("P: ", players)
			print("E: ", enemies)
			last_debug = curr_time

# Tally up the units if we haven't already done so
func fetch_all_units():
	var unit_root = get_node("/root/Main/Units")
	for child in unit_root.get_children():
		if child.is_in_group("Unit"):
			if child.unit_team == Constants.UnitTeam.PLAYER:
				players.append(child)
			if child.unit_team == Constants.UnitTeam.ENEMY:
				enemies.append(child)

# Removes scene units removed by queue_free()
func recount_unit_registers(register :Array[CharacterBody2D]) -> Array[CharacterBody2D]:
	var clean_array :Array[CharacterBody2D] = []
	for unit in register:
		if is_instance_valid(unit):
			clean_array.append(unit)
	return clean_array
	
func _input(event):
#	# Single selection
#	if event is InputEventMouseButton:
#		if Input.is_action_pressed("LMB"):
#			try_select_single_unit()
#		if Input.is_action_pressed("RMB"):
#			try_command_units()

	# Multi selection
	if event is InputEventMouseButton:
		if Input.is_action_pressed("LMB"):
			try_select_single_unit()
			if selected_units.is_empty():
				if !dragging:
					drag_start = get_global_mouse_position()
					dragging = true
		elif Input.is_action_just_released("LMB"):
			if dragging:
				dragging = false
				queue_redraw()
				try_select_multiple_units()
		elif Input.is_action_pressed("RMB"):
			try_command_units()
	elif event is InputEventMouseMotion and dragging:
		queue_redraw()
		drag_end = get_global_mouse_position()

#func _input(event):
#	# If it is mouse input
#	if event is InputEventMouseButton:
#		# And it's LMB press
#		if Input.is_action_pressed("LMB"):
#			# Try to set the target
#			# If there's nothing there and we have no units currently selected,
#			# - enter dragging mode
#			# - set the start position of the multi-unit check area
#			try_select_single_unit()
#			if selected_units.size() == 0:
#				if !dragging:
#					drag_start = get_global_mouse_position()
#					dragging = true
#		# And it's LMB release
#		elif Input.is_action_just_released("LMB"):
#			# If we're in dragging mode:
#			# - draw the feedback area rect
#			# - check the space for friendly units under the area
#			if dragging:
#				dragging = false
#				queue_redraw()
#				find_units_in_area()
#				try_select_multiple_units()
#		elif Input.is_action_pressed("RMB"):
#			try_command_unit()
#			selected_tmp.clear()
#	elif event is InputEventMouseMotion and dragging:
#		queue_redraw()
#		drag_end = get_global_mouse_position()

# Draw the multi-unit selector borders while dragging
func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start), Color(1, 0, 1, 1), false)
#		draw_circle(drag_start,5,Color.BLUE)

# Area check for multiple selected units within the bounds of the mouse LMB+drag window
# - Checks that objects are units and belong to the player
func find_units_in_area():
	select_rect.extents = (drag_end - drag_start) / 2
	var space = get_world_2d().direct_space_state
	var shape_query = PhysicsShapeQueryParameters2D.new()
	shape_query.set_shape(select_rect)
	shape_query.transform = Transform2D(0, (drag_end + drag_start) / 2)
	
	var selected_objects = space.intersect_shape(shape_query)
	if selected_objects.is_empty():
		return null
	
	var _selected_units = []
	for item in selected_objects:
		var unit = item["collider"]
		if unit.get_parent().name == "Units" and unit.unit_team == Constants.UnitTeam.PLAYER:
			_selected_units.append(unit)
	select_rect = RectangleShape2D.new()
	return _selected_units

# Single point check for selected unit
# Returns whatever is clicked
func find_unit_at_point():
	# Get the space state
	var space = get_world_2d().direct_space_state
	# Create a space state query
	var point_query = PhysicsPointQueryParameters2D.new()
	# Use the mouse position for the space query
	point_query.position = get_global_mouse_position()
	
	# Check if anything is under the mouse
	var selected_objects = space.intersect_point(point_query, 1)
	if selected_objects.is_empty():
		return null

	var item = selected_objects[0]
	return item["collider"]

func try_select_multiple_units():
	unselect_units()
	var units_to_select = find_units_in_area()
	if units_to_select != null:
		for unit in units_to_select:
			selected_units.append(unit)
		select_units()

# Select unit with left click
func try_select_single_unit():
	unselect_units()
	var unit = find_unit_at_point()
	if unit != null:
		selected_units.append(unit)
	select_units()

func select_units():
	for _unit in selected_units:
		_unit.toggle_selection_visual(true)

func select_unit(unit):
	unit.toggle_selection_visual(true)

# Turn of selection indicators for all currently selected units
# Wipe the selection list
func unselect_units():
	for unit in selected_units:
		unit.toggle_selection_visual(false)
	selected_units.clear()

# On RMB, appropriately command units based on what was targeted, and the selected unit's class
func try_command_units():
	# Don't do anything if a unit isn't selected
	if selected_units.size() == 0:
		return
	
	# If we right click on a unit/resource/etc, set that as our target
	var target = find_unit_at_point()
	if target != null:
		if target.name.contains("ResourceUnit"):
			var gatherers = filter_selected_units_by_name("GathererUnit")
			for unit in gatherers:
				unit.set_target(target)
			flash_locator(selected_location, target.position)
		elif target.name.contains("SoldierUnit"):
			var healers = filter_selected_units_by_name("HealerUnit")
			for unit in healers:
				unit.set_target(target)
			flash_locator(selected_location, target.position)
		elif target.name.contains("EnemyUnit"):
			var soldiers = filter_selected_units_by_name("SoldierUnit")
			for unit in soldiers:
				unit.set_target(target)
			flash_locator(enemy_location, target.position)
	else:
		var target_location :Vector2 = get_global_mouse_position()
		flash_locator(selected_location, target_location)
		for unit in selected_units:
			unit.move_to_location(target_location)

func filter_selected_units_by_name(filter :String):
	var subset = []
	for unit in selected_units:
		if unit.name.contains(filter):
			subset.append(unit)
	return subset
	
func flash_locator(locator :PackedScene, position :Vector2):
	var _locator = locator.instantiate()
	var body = _locator.get_node("CharacterBody2D")
	_locator.position = position
	add_child(_locator)
