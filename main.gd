extends Node
class_name Main

# JagQuest Main Controller
# Manages game states: Overworld (Campus View) ↔ Room View
# Handles transitions and JagGenie integration
#
# Teleport Modes:
# - NAVIGATE: Default. Moves player to grid location in overworld
# - TELEPORT: Optional. Goes directly into building/room interior

enum GameState {
	CAMPUS_VIEW,    # Overworld - navigating the campus map
	ROOM_VIEW,      # Inside a program room/building
	TRANSITIONING   # Playing transition animation
}

var current_state: GameState = GameState.CAMPUS_VIEW

# Scene references
@onready var overworld: Overworld = $Overworld
@onready var jag_genie: JagGenie = $JagGenie
@onready var transition_rect: ColorRect = $TransitionLayer/TransitionRect

# Current room (if in ROOM_VIEW)
var current_room: Node = null
var current_entity_id: String = ""

# Preload room scene
var ProgramRoomScene = preload("res://Rooms/program_room.tscn")

func _ready() -> void:
	_connect_signals()
	_setup_initial_state()

func _connect_signals() -> void:
	# JagGenie signals
	jag_genie.location_selected.connect(_on_jag_genie_action)
	jag_genie.navigate_to.connect(_on_jag_genie_navigate)
	jag_genie.closed.connect(_on_jag_genie_closed)
	
	# Overworld signals
	overworld.building_entered.connect(_on_building_entered)

func _setup_initial_state() -> void:
	current_state = GameState.CAMPUS_VIEW
	overworld.visible = true
	jag_genie.visible = false
	transition_rect.color = Color(0, 0, 0, 0)

func _input(event: InputEvent) -> void:
	# Global JagGenie toggle (Tab or G)
	if event.is_action_pressed("jaggenie") and current_state == GameState.CAMPUS_VIEW:
		_open_jag_genie()
	
	# Exit room with Escape
	if event.is_action_pressed("ui_cancel") and current_state == GameState.ROOM_VIEW:
		_exit_room()

func _open_jag_genie() -> void:
	jag_genie.open()

func _on_jag_genie_closed() -> void:
	pass  # Resume normal gameplay

# Handle navigation in overworld (default action - teleport to grid location)
func _on_jag_genie_navigate(position: Vector2) -> void:
	if current_state != GameState.CAMPUS_VIEW:
		return
	
	# Teleport player to position in overworld
	overworld.teleport_to_position(position)

# Handle JagGenie selection action
func _on_jag_genie_action(entity_id: String, entity_type: String, action_type: int) -> void:
	if current_state != GameState.CAMPUS_VIEW:
		return
	
	# Default behavior: Navigate to overworld location
	# All entities now default to NAVIGATE action
	match entity_type:
		"building":
			overworld.teleport_to_building(entity_id)
		"program":
			# Get the program's building and teleport there
			var program = GameData.get_program(entity_id)
			if not program.is_empty():
				var building_id = program.get("building_id", "")
				if not building_id.is_empty():
					overworld.teleport_to_building(building_id)
		"person":
			# Teleport to person's building location
			var staff = GameData.get_staff(entity_id)
			if not staff.is_empty():
				var building_id = staff.get("building_id", "")
				if not building_id.is_empty():
					overworld.teleport_to_building(building_id)
		"resource":
			# Teleport to resource location
			var grid_location = ""
			for key in GameData.RESOURCES:
				if GameData.RESOURCES[key].get("id") == entity_id:
					grid_location = GameData.RESOURCES[key].get("grid_location", "")
					break
			if not grid_location.is_empty():
				overworld.teleport_to_grid(grid_location)

# Handle building entry from overworld (click or E key on building)
func _on_building_entered(building_id: String) -> void:
	if current_state != GameState.CAMPUS_VIEW:
		return
	
	# Get programs in this building
	var programs = GameData.get_programs_in_building(building_id)
	
	if programs.size() == 1:
		# Single program - enter directly
		_enter_program_room(programs[0].get("id", ""))
	elif programs.size() > 1:
		# Multiple programs - could show a selection UI
		# For now, enter the first one
		_enter_program_room(programs[0].get("id", ""))
	else:
		# No programs - just a building (like Student Services)
		# Could show building info or services menu
		print("Building has no programs: ", building_id)

func _enter_program_room(program_id: String) -> void:
	if current_state != GameState.CAMPUS_VIEW:
		return
	
	var program = GameData.get_program(program_id)
	if program.is_empty():
		print("Program not found: ", program_id)
		return
	
	current_state = GameState.TRANSITIONING
	current_entity_id = program_id
	
	# Play transition
	await _play_enter_transition()
	
	# Load room
	_load_room(program_id)
	
	current_state = GameState.ROOM_VIEW

func _load_room(program_id: String) -> void:
	# Hide overworld
	overworld.visible = false
	
	# Create room instance
	current_room = ProgramRoomScene.instantiate()
	current_room.program_id = program_id
	if current_room.has_signal("exit_requested"):
		current_room.exit_requested.connect(_on_room_exit_requested)
	add_child(current_room)

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
	var tween = create_tween()
	tween.tween_property(transition_rect, "color", Color(0, 0, 0, 1), 0.3)
	await tween.finished
	await get_tree().create_timer(0.1).timeout
	tween = create_tween()
	tween.tween_property(transition_rect, "color", Color(0, 0, 0, 0), 0.3)
	await tween.finished

func _play_exit_transition() -> void:
	await _play_enter_transition()
