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
@onready var camera: Camera2D = $Player/Camera2D

# State
var current_hovered_building: String = ""
var current_selected_building: String = ""
var is_mouse_navigation: bool = false
var target_position: Vector2 = Vector2.ZERO

# Campus map dimensions (will be set based on actual map image)
const MAP_WIDTH: float = 1920.0
const MAP_HEIGHT: float = 1080.0

func _ready() -> void:
	_setup_buildings()
	_connect_signals()

func _setup_buildings() -> void:
	# Create clickable/hoverable areas for each building
	var GameData = preload("res://Data/game_data.gd")
	
	for building_id in GameData.BUILDINGS:
		var building_data = GameData.BUILDINGS[building_id]
		var building_area = _create_building_area(building_id, building_data)
		buildings_container.add_child(building_area)

func _create_building_area(building_id: String, data: Dictionary) -> Area2D:
	var area = Area2D.new()
	area.name = "Building_" + building_id
	
	# Position based on normalized map coordinates
	var map_pos = data["map_position"]
	area.position = Vector2(map_pos.x * MAP_WIDTH, map_pos.y * MAP_HEIGHT)
	
	# Create collision shape (building footprint)
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 40)  # Adjust based on building size
	collision.shape = shape
	area.add_child(collision)
	
	# Create visual indicator
	var sprite = Sprite2D.new()
	sprite.name = "BuildingSprite"
	# Will be replaced with actual building icons
	area.add_child(sprite)
	
	# Create label
	var label = Label.new()
	label.name = "BuildingLabel"
	label.text = data["name"]
	label.position = Vector2(-30, -30)
	label.add_theme_font_size_override("font_size", 10)
	area.add_child(label)
	
	# Store building data
	area.set_meta("building_id", building_id)
	area.set_meta("building_data", data)
	
	# Connect signals
	area.mouse_entered.connect(_on_building_hover_enter.bind(building_id))
	area.mouse_exited.connect(_on_building_hover_exit.bind(building_id))
	area.input_event.connect(_on_building_input.bind(building_id))
	
	# Also detect player collision
	area.body_entered.connect(_on_player_enter_building.bind(building_id))
	area.body_exited.connect(_on_player_exit_building.bind(building_id))
	
	return area

func _connect_signals() -> void:
	pass

func _input(event: InputEvent) -> void:
	# JagGenie activation (Tab or G key)
	if event.is_action_pressed("jaggenie"):
		jaggenie_requested.emit()
	
	# Mouse click for navigation
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_start_mouse_navigation(get_global_mouse_position())
	
	# Keyboard takes priority over mouse
	if event is InputEventKey:
		is_mouse_navigation = false

func _start_mouse_navigation(target: Vector2) -> void:
	is_mouse_navigation = true
	target_position = target

func _physics_process(delta: float) -> void:
	if is_mouse_navigation:
		_handle_mouse_navigation(delta)

func _handle_mouse_navigation(delta: float) -> void:
	var direction = (target_position - player.position).normalized()
	var distance = player.position.distance_to(target_position)
	
	if distance > 5:
		player.velocity = direction * player.MAX_SPEED
	else:
		player.velocity = Vector2.ZERO
		is_mouse_navigation = false

# Building interaction handlers
func _on_building_hover_enter(building_id: String) -> void:
	current_hovered_building = building_id
	_highlight_building(building_id, true)
	building_selected.emit(building_id)

func _on_building_hover_exit(building_id: String) -> void:
	if current_hovered_building == building_id:
		current_hovered_building = ""
	_highlight_building(building_id, false)

func _on_building_input(viewport: Node, event: InputEvent, shape_idx: int, building_id: String) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_enter_building(building_id)

func _on_player_enter_building(body: Node2D, building_id: String) -> void:
	if body == player:
		current_selected_building = building_id
		_highlight_building(building_id, true)
		building_selected.emit(building_id)

func _on_player_exit_building(body: Node2D, building_id: String) -> void:
	if body == player:
		if current_selected_building == building_id:
			current_selected_building = ""
		_highlight_building(building_id, false)

func _highlight_building(building_id: String, highlight: bool) -> void:
	var building_node = buildings_container.get_node_or_null("Building_" + building_id)
	if building_node:
		var label = building_node.get_node_or_null("BuildingLabel")
		if label:
			if highlight:
				label.add_theme_color_override("font_color", Color.GOLD)
			else:
				label.remove_theme_color_override("font_color")

func _enter_building(building_id: String) -> void:
	print("Entering building: ", building_id)
	building_entered.emit(building_id)

# Teleport player to a building (used by JagGenie)
func teleport_to_building(building_id: String) -> void:
	var GameData = preload("res://Data/game_data.gd")
	if GameData.BUILDINGS.has(building_id):
		var building_data = GameData.BUILDINGS[building_id]
		var map_pos = building_data["map_position"]
		var target = Vector2(map_pos.x * MAP_WIDTH, map_pos.y * MAP_HEIGHT)
		
		# Play teleport animation
		_play_teleport_animation(player.position, target)
		player.position = target

func _play_teleport_animation(from: Vector2, to: Vector2) -> void:
	# TODO: Add sparkle/transition effect
	pass
