extends Node
class_name Main

# JagQuest Main Controller
# Manages game states: Overworld (Campus View) ↔ Room View
# Handles transitions and JagGenie integration

enum GameState {
	CAMPUS_VIEW,    # Overworld - navigating the campus map
	ROOM_VIEW,      # Inside a program room
	TRANSITIONING   # Playing transition animation
}

var current_state: GameState = GameState.CAMPUS_VIEW

# Scene references
@onready var overworld: Overworld = $Overworld
@onready var jag_genie: JagGenie = $JagGenie
@onready var transition_layer: CanvasLayer = $TransitionLayer
@onready var transition_rect: ColorRect = $TransitionLayer/TransitionRect

# Current room (if in ROOM_VIEW)
var current_room: ProgramRoom = null
var current_building_id: String = ""

# Preload room scene template
const ProgramRoomScene = preload("res://Rooms/program_room.tscn") if ResourceLoader.exists("res://Rooms/program_room.tscn") else null

var GameData = preload("res://Data/game_data.gd")

func _ready() -> void:
	_connect_signals()
	_setup_initial_state()

func _connect_signals() -> void:
	# Overworld signals
	overworld.building_entered.connect(_on_building_entered)
	overworld.building_selected.connect(_on_building_selected)
	overworld.jaggenie_requested.connect(_open_jag_genie)
	
	# JagGenie signals
	jag_genie.location_selected.connect(_on_jag_genie_selected)
	jag_genie.closed.connect(_on_jag_genie_closed)

func _setup_initial_state() -> void:
	current_state = GameState.CAMPUS_VIEW
	overworld.visible = true
	jag_genie.visible = false
	transition_rect.color = Color(0, 0, 0, 0)

func _input(event: InputEvent) -> void:
	# Global JagGenie toggle (Tab or G)
	if event.is_action_pressed("jaggenie"):
		if current_state == GameState.CAMPUS_VIEW:
			_open_jag_genie()

func _open_jag_genie() -> void:
	jag_genie.open()

func _on_jag_genie_closed() -> void:
	pass  # Resume normal gameplay

func _on_jag_genie_selected(entity_id: String, entity_type: String) -> void:
	match entity_type:
		"building":
			# Teleport to building on campus
			overworld.teleport_to_building(entity_id)
		"program":
			# Teleport to program's building, then optionally enter
			var program = GameData.get_program(entity_id)
			if not program.is_empty():
				var building_id = program.get("building_id", "")
				overworld.teleport_to_building(building_id)
				# Optionally auto-enter the building
				# _enter_building(building_id)
		"person":
			# Teleport to person's office building
			var staff = GameData.STAFF.get(entity_id, {})
			if not staff.is_empty():
				var building_id = staff.get("building_id", "")
				overworld.teleport_to_building(building_id)

func _on_building_selected(building_id: String) -> void:
	current_building_id = building_id
	_show_building_info(building_id)

func _on_building_entered(building_id: String) -> void:
	_enter_building(building_id)

func _show_building_info(building_id: String) -> void:
	var building = GameData.get_building(building_id)
	if building.is_empty():
		return
	
	# Update UI to show building info
	var info_panel = overworld.get_node_or_null("UI/BuildingInfo")
	if info_panel:
		info_panel.visible = true
		var name_label = info_panel.get_node_or_null("BuildingName")
		if name_label:
			name_label.text = building.get("name", "")
		var desc_label = info_panel.get_node_or_null("BuildingDescription")
		if desc_label:
			desc_label.text = building.get("description", "")

func _enter_building(building_id: String) -> void:
	if current_state != GameState.CAMPUS_VIEW:
		return
	
	current_state = GameState.TRANSITIONING
	current_building_id = building_id
	
	# Get programs in this building
	var programs = GameData.get_programs_in_building(building_id)
	
	if programs.is_empty():
		# Building has no programs - just show info
		print("No programs in building: ", building_id)
		current_state = GameState.CAMPUS_VIEW
		return
	
	# For now, enter the first program's room
	# TODO: Show selection if multiple programs
	var program = programs[0]
	
	# Play transition
	await _play_enter_transition()
	
	# Load and show room
	_load_room(program["id"])
	
	current_state = GameState.ROOM_VIEW

func _load_room(program_id: String) -> void:
	# Hide overworld
	overworld.visible = false
	
	# Create room instance
	if ProgramRoomScene:
		current_room = ProgramRoomScene.instantiate()
		current_room.setup(program_id)
		current_room.exit_requested.connect(_on_room_exit_requested)
		add_child(current_room)
	else:
		# Fallback: create basic room
		_create_basic_room(program_id)

func _create_basic_room(program_id: String) -> void:
	var program = GameData.get_program(program_id)
	
	# Create a simple room display
	var room = Node2D.new()
	room.name = "Room_" + program_id
	
	# Background
	var bg = ColorRect.new()
	bg.size = Vector2(320, 180)
	bg.color = program.get("theme_color", Color(0.2, 0.2, 0.3))
	room.add_child(bg)
	
	# Title
	var title = Label.new()
	title.text = program.get("name", "Program Room")
	title.position = Vector2(100, 20)
	title.add_theme_font_size_override("font_size", 16)
	room.add_child(title)
	
	# Description
	var desc = Label.new()
	desc.text = program.get("description", "")
	desc.position = Vector2(20, 60)
	desc.size = Vector2(280, 100)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.add_theme_font_size_override("font_size", 10)
	room.add_child(desc)
	
	# Exit hint
	var exit_hint = Label.new()
	exit_hint.text = "Press ESC to exit"
	exit_hint.position = Vector2(100, 160)
	exit_hint.add_theme_font_size_override("font_size", 8)
	room.add_child(exit_hint)
	
	current_room = room
	add_child(room)

func _on_room_exit_requested() -> void:
	_exit_room()

func _exit_room() -> void:
	if current_state != GameState.ROOM_VIEW:
		return
	
	current_state = GameState.TRANSITIONING
	
	# Play transition
	await _play_exit_transition()
	
	# Remove room
	if current_room:
		current_room.queue_free()
		current_room = null
	
	# Show overworld
	overworld.visible = true
	
	current_state = GameState.CAMPUS_VIEW

func _play_enter_transition() -> void:
	# Fade to black
	var tween = create_tween()
	tween.tween_property(transition_rect, "color", Color(0, 0, 0, 1), 0.3)
	await tween.finished
	
	# Brief pause
	await get_tree().create_timer(0.1).timeout
	
	# Fade from black
	tween = create_tween()
	tween.tween_property(transition_rect, "color", Color(0, 0, 0, 0), 0.3)
	await tween.finished

func _play_exit_transition() -> void:
	await _play_enter_transition()  # Same animation for now
