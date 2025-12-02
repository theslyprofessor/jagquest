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
@onready var transition_rect: ColorRect = $TransitionLayer/TransitionRect

# Current room (if in ROOM_VIEW)
var current_room: Node = null
var current_building_id: String = ""

# Preload
var GameData = preload("res://Data/game_data.gd")
var ProgramRoomScene = preload("res://Rooms/program_room.tscn")

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
	if event.is_action_pressed("jaggenie") and current_state == GameState.CAMPUS_VIEW:
		_open_jag_genie()
	
	# Exit room with Escape
	if event.is_action_pressed("ui_cancel") and current_state == GameState.ROOM_VIEW:
		_exit_room()

func _open_jag_genie() -> void:
	jag_genie.open()

func _on_jag_genie_closed() -> void:
	pass  # Resume normal gameplay

func _on_jag_genie_selected(entity_id: String, entity_type: String) -> void:
	match entity_type:
		"building":
			overworld.teleport_to_building(entity_id)
		"program":
			var program = GameData.get_program(entity_id)
			if not program.is_empty():
				var building_id = program.get("building_id", "")
				overworld.teleport_to_building(building_id)
		"person":
			var staff = GameData.STAFF.get(entity_id, {})
			if not staff.is_empty():
				var building_id = staff.get("building_id", "")
				overworld.teleport_to_building(building_id)

func _on_building_selected(building_id: String) -> void:
	current_building_id = building_id

func _on_building_entered(building_id: String) -> void:
	_enter_building(building_id)

func _enter_building(building_id: String) -> void:
	if current_state != GameState.CAMPUS_VIEW:
		return
	
	current_state = GameState.TRANSITIONING
	current_building_id = building_id
	
	# Get programs in this building
	var programs = GameData.get_programs_in_building(building_id)
	
	if programs.is_empty():
		print("No programs in building: ", building_id)
		current_state = GameState.CAMPUS_VIEW
		return
	
	# Enter the first program's room
	var program = programs[0]
	
	# Play transition
	await _play_enter_transition()
	
	# Load room
	_load_room(program["id"])
	
	current_state = GameState.ROOM_VIEW

func _load_room(program_id: String) -> void:
	# Hide overworld
	overworld.visible = false
	
	# Create room instance
	current_room = ProgramRoomScene.instantiate()
	current_room.program_id = program_id
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
