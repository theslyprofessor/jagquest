extends Node2D
class_name Overworld

# Overworld - "Campus View" mode
# The base layer showing the SWC campus map with interactive buildings
# Uses grid coordinates from official campus map (A-H columns, 1-8 rows)

signal building_selected(building_id: String)
signal building_entered(building_id: String)
signal jaggenie_requested
signal location_hovered(entities: Array, grid_location: String)

# References
@onready var player: CharacterBody2D = $Player
@onready var campus_map: Sprite2D = $CampusMap
@onready var buildings_container: Node2D = $Buildings
@onready var building_info_panel: Panel = $UI/BuildingInfo
@onready var building_name_label: Label = $UI/BuildingInfo/VBox/BuildingName
@onready var building_desc_label: Label = $UI/BuildingInfo/VBox/BuildingDescription
@onready var programs_list_label: Label = $UI/BuildingInfo/VBox/ProgramsList

# State
var current_hovered_building: String = ""
var current_selected_building: String = ""
var is_mouse_navigation: bool = false
var target_position: Vector2 = Vector2.ZERO

# Shared location state (multiple entities at same grid position)
var current_location_entities: Array = []
var current_location_index: int = 0

# Map dimensions - reference player constants (single source of truth)
# These are calculated from SVG_SCALE in player.gd
const MAP_WIDTH: float = JaguarPlayer.PLAYABLE_WIDTH
const MAP_HEIGHT: float = JaguarPlayer.PLAYABLE_HEIGHT

func _ready() -> void:
	_setup_campus_map()
	_setup_buildings()
	building_info_panel.visible = false

func _setup_campus_map() -> void:
	# Position map at origin (top-left), not centered
	if campus_map:
		campus_map.centered = false
		campus_map.position = Vector2.ZERO

func _setup_buildings() -> void:
	# Create clickable/hoverable areas for each building
	for building_id in GameData.BUILDINGS:
		var building_data = GameData.get_building(building_id)
		var building_area = _create_building_area(building_id, building_data)
		buildings_container.add_child(building_area)

func _create_building_area(building_id: String, data: Dictionary) -> Area2D:
	var area = Area2D.new()
	area.name = "Building_" + building_id
	area.collision_layer = 4  # Interactables layer
	area.collision_mask = 1   # Detect player
	
	# Position based on grid coordinates
	var grid_location = data.get("grid_location", "D4")
	var normalized_pos = GameData.grid_to_position(grid_location)
	area.position = Vector2(normalized_pos.x * MAP_WIDTH, normalized_pos.y * MAP_HEIGHT)
	
	# Create collision shape (building footprint)
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 50)  # Building hit area
	collision.shape = shape
	area.add_child(collision)
	
	# Add visual marker for building (debug/placeholder)
	var marker = ColorRect.new()
	marker.size = Vector2(20, 20)
	marker.position = Vector2(-10, -10)
	marker.color = Color(0.2, 0.6, 0.9, 0.5)
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(marker)
	
	# Store building data
	area.set_meta("building_id", building_id)
	area.set_meta("grid_location", grid_location)
	
	# Connect signals for mouse interaction
	area.mouse_entered.connect(_on_building_hover_enter.bind(building_id, grid_location))
	area.mouse_exited.connect(_on_building_hover_exit.bind(building_id))
	area.input_event.connect(_on_building_input.bind(building_id))
	
	# Connect for player collision
	area.body_entered.connect(_on_player_enter_building.bind(building_id, grid_location))
	area.body_exited.connect(_on_player_exit_building.bind(building_id))
	
	return area

func _input(event: InputEvent) -> void:
	# JagGenie activation (Tab or G key)
	if event.is_action_pressed("jaggenie"):
		jaggenie_requested.emit()
	
	# Enter building with E key
	if event.is_action_pressed("interact") and current_selected_building != "":
		_enter_building(current_selected_building)
	
	# Backslash to cycle through entities at same location
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACKSLASH and current_location_entities.size() > 1:
			_cycle_location_entity()
	
	# Option+Click for navigation (not regular click)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Option+Click to navigate (player.gd handles this)
			# Regular click on building to enter it
			if not event.alt_pressed and current_hovered_building != "":
				_enter_building(current_hovered_building)

func _start_mouse_navigation(target: Vector2) -> void:
	is_mouse_navigation = true
	target_position = target
	if player.has_method("set_nav_mode"):
		player.nav_mode = player.NavMode.MOUSE
		player.mouse_target = target

func _physics_process(_delta: float) -> void:
	pass  # Player handles its own movement

# Cycle through multiple entities at same grid location
func _cycle_location_entity() -> void:
	if current_location_entities.size() <= 1:
		return
	
	current_location_index = (current_location_index + 1) % current_location_entities.size()
	var entity = current_location_entities[current_location_index]
	_show_entity_info(entity)

# Building interaction handlers
func _on_building_hover_enter(building_id: String, grid_location: String) -> void:
	current_hovered_building = building_id
	
	# Get all entities at this grid location
	current_location_entities = GameData.get_entities_at_grid(grid_location)
	current_location_index = 0
	
	# Find the building in the list and show it first
	for i in range(current_location_entities.size()):
		if current_location_entities[i].get("id") == building_id:
			current_location_index = i
			break
	
	if current_location_entities.size() > 0:
		_show_entity_info(current_location_entities[current_location_index])
	
	location_hovered.emit(current_location_entities, grid_location)
	building_selected.emit(building_id)

func _on_building_hover_exit(building_id: String) -> void:
	if current_hovered_building == building_id:
		current_hovered_building = ""
		current_location_entities = []
		current_location_index = 0
	if current_selected_building == "":
		building_info_panel.visible = false

func _on_building_input(viewport: Node, event: InputEvent, shape_idx: int, building_id: String) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_enter_building(building_id)

func _on_player_enter_building(body: Node2D, building_id: String, grid_location: String) -> void:
	if body == player:
		current_selected_building = building_id
		
		# Get all entities at this grid location
		current_location_entities = GameData.get_entities_at_grid(grid_location)
		current_location_index = 0
		
		if current_location_entities.size() > 0:
			_show_entity_info(current_location_entities[current_location_index])
		
		location_hovered.emit(current_location_entities, grid_location)
		building_selected.emit(building_id)

func _on_player_exit_building(body: Node2D, building_id: String) -> void:
	if body == player:
		if current_selected_building == building_id:
			current_selected_building = ""
			current_location_entities = []
			current_location_index = 0
		if current_hovered_building == "":
			building_info_panel.visible = false

func _show_entity_info(entity: Dictionary) -> void:
	if entity.is_empty():
		return
	
	building_info_panel.visible = true
	
	var search_type = entity.get("search_type", "building")
	var name = entity.get("name", entity.get("short_name", "Unknown"))
	var description = entity.get("description", "")
	
	# Add grid location and entity count
	var grid = entity.get("grid_location", "")
	var location_hint = ""
	if not grid.is_empty():
		location_hint = " [Grid " + grid + "]"
	
	# Show if multiple entities at this location
	if current_location_entities.size() > 1:
		location_hint += " (" + str(current_location_index + 1) + "/" + str(current_location_entities.size()) + " - Press \\ to cycle)"
	
	building_name_label.text = name + location_hint
	building_desc_label.text = description
	
	# Show related programs or info based on type
	match search_type:
		"building":
			var programs = entity.get("programs", [])
			if programs.size() > 0:
				var program_names = []
				for prog_id in programs:
					var prog = GameData.get_program(prog_id)
					if not prog.is_empty():
						program_names.append(prog.get("name", prog_id))
				programs_list_label.text = "Programs: " + ", ".join(program_names)
			else:
				var departments = entity.get("departments", [])
				if departments.size() > 0:
					programs_list_label.text = "Services: " + ", ".join(departments)
				else:
					programs_list_label.text = ""
		"program":
			var dept = entity.get("department", "")
			var building_id = entity.get("building_id", "")
			var building = GameData.get_building(building_id)
			var building_name = building.get("short_name", building_id) if not building.is_empty() else building_id
			programs_list_label.text = dept + " Dept • Building " + building_name
		"person":
			programs_list_label.text = entity.get("title", "") + " • Office " + entity.get("office", "")
		_:
			programs_list_label.text = ""

func _show_building_info(building_id: String) -> void:
	var building = GameData.get_building(building_id)
	if building.is_empty():
		return
	
	building["search_type"] = "building"
	_show_entity_info(building)

func _enter_building(building_id: String) -> void:
	print("Entering building: ", building_id)
	building_entered.emit(building_id)

# Teleport player to a position (used by JagGenie)
func teleport_to_position(normalized_pos: Vector2) -> void:
	var target = Vector2(normalized_pos.x * MAP_WIDTH, normalized_pos.y * MAP_HEIGHT)
	if player and player.has_method("teleport_to"):
		player.teleport_to(target)

# Teleport player to a building (used by JagGenie)
func teleport_to_building(building_id: String) -> void:
	var building = GameData.get_building(building_id)
	if building.is_empty():
		return
	
	var grid_location = building.get("grid_location", "D4")
	var normalized_pos = GameData.grid_to_position(grid_location)
	teleport_to_position(normalized_pos)
	
	# Show building info
	_show_building_info(building_id)
	current_selected_building = building_id

# Teleport player to a grid location
func teleport_to_grid(grid_location: String) -> void:
	var normalized_pos = GameData.grid_to_position(grid_location)
	teleport_to_position(normalized_pos)
