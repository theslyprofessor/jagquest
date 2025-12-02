extends Node2D
class_name Overworld

# Overworld - "Campus View" mode
# The base layer showing the SWC campus map with interactive buildings

signal building_selected(building_id: String)
signal building_entered(building_id: String)
signal jaggenie_requested

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

# Campus map dimensions (matches the SVG)
const MAP_WIDTH: float = 1920.0
const MAP_HEIGHT: float = 1080.0

# Preload game data
var GameData = preload("res://Data/game_data.gd")

func _ready() -> void:
	_setup_buildings()
	building_info_panel.visible = false

func _setup_buildings() -> void:
	# Create clickable/hoverable areas for each building
	for building_id in GameData.BUILDINGS:
		var building_data = GameData.BUILDINGS[building_id]
		var building_area = _create_building_area(building_id, building_data)
		buildings_container.add_child(building_area)

func _create_building_area(building_id: String, data: Dictionary) -> Area2D:
	var area = Area2D.new()
	area.name = "Building_" + building_id
	area.collision_layer = 4  # Interactables layer
	area.collision_mask = 1   # Detect player
	
	# Position based on normalized map coordinates
	var map_pos = data["map_position"]
	area.position = Vector2(map_pos.x * MAP_WIDTH, map_pos.y * MAP_HEIGHT)
	
	# Create collision shape (building footprint)
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(80, 60)  # Building hit area
	collision.shape = shape
	area.add_child(collision)
	
	# Store building data
	area.set_meta("building_id", building_id)
	area.set_meta("building_data", data)
	
	# Connect signals for mouse interaction
	area.mouse_entered.connect(_on_building_hover_enter.bind(building_id))
	area.mouse_exited.connect(_on_building_hover_exit.bind(building_id))
	area.input_event.connect(_on_building_input.bind(building_id))
	
	# Connect for player collision
	area.body_entered.connect(_on_player_enter_building.bind(building_id))
	area.body_exited.connect(_on_player_exit_building.bind(building_id))
	
	return area

func _input(event: InputEvent) -> void:
	# JagGenie activation (Tab or G key)
	if event.is_action_pressed("jaggenie"):
		jaggenie_requested.emit()
	
	# Enter building with E key
	if event.is_action_pressed("interact") and current_selected_building != "":
		_enter_building(current_selected_building)
	
	# Mouse click for navigation
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Check if clicking on a building
			if current_hovered_building != "":
				_enter_building(current_hovered_building)
			else:
				_start_mouse_navigation(get_global_mouse_position())

func _start_mouse_navigation(target: Vector2) -> void:
	is_mouse_navigation = true
	target_position = target
	player.nav_mode = player.NavMode.MOUSE
	player.mouse_target = target

func _physics_process(_delta: float) -> void:
	pass  # Player handles its own movement

# Building interaction handlers
func _on_building_hover_enter(building_id: String) -> void:
	current_hovered_building = building_id
	_show_building_info(building_id)
	building_selected.emit(building_id)

func _on_building_hover_exit(building_id: String) -> void:
	if current_hovered_building == building_id:
		current_hovered_building = ""
	if current_selected_building == "":
		building_info_panel.visible = false

func _on_building_input(viewport: Node, event: InputEvent, shape_idx: int, building_id: String) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_enter_building(building_id)

func _on_player_enter_building(body: Node2D, building_id: String) -> void:
	if body == player:
		current_selected_building = building_id
		_show_building_info(building_id)
		building_selected.emit(building_id)

func _on_player_exit_building(body: Node2D, building_id: String) -> void:
	if body == player:
		if current_selected_building == building_id:
			current_selected_building = ""
		if current_hovered_building == "":
			building_info_panel.visible = false

func _show_building_info(building_id: String) -> void:
	var building = GameData.BUILDINGS.get(building_id, {})
	if building.is_empty():
		return
	
	building_info_panel.visible = true
	building_name_label.text = building.get("name", "Unknown")
	building_desc_label.text = building.get("description", "")
	
	# Show programs in this building
	var programs = building.get("programs", [])
	if programs.size() > 0:
		var program_names = []
		for prog_id in programs:
			var prog = GameData.PROGRAMS.get(prog_id, {})
			if not prog.is_empty():
				program_names.append(prog.get("name", prog_id))
		programs_list_label.text = "Programs: " + ", ".join(program_names)
	else:
		programs_list_label.text = ""

func _enter_building(building_id: String) -> void:
	print("Entering building: ", building_id)
	building_entered.emit(building_id)

# Teleport player to a building (used by JagGenie)
func teleport_to_building(building_id: String) -> void:
	if GameData.BUILDINGS.has(building_id):
		var building_data = GameData.BUILDINGS[building_id]
		var map_pos = building_data["map_position"]
		var target = Vector2(map_pos.x * MAP_WIDTH, map_pos.y * MAP_HEIGHT)
		
		# Teleport player
		player.teleport_to(target)
		
		# Show building info
		_show_building_info(building_id)
		current_selected_building = building_id
