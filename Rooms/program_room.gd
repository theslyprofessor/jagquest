extends Node2D
class_name ProgramRoom

# Program Room - Interior view for each academic program
# Zelda-style room with program information

signal exit_requested

# Room configuration
@export var program_id: String = ""

# References
@onready var player = $Player
@onready var background: ColorRect = $Background
@onready var floor_rect: ColorRect = $Floor
@onready var room_name_label: Label = $UI/RoomName
@onready var info_panel: Panel = $UI/InfoPanel
@onready var exit_area: Area2D = $ExitArea

# Room data
var program_data: Dictionary = {}
var GameData = preload("res://Data/game_data.gd")

func _ready() -> void:
	_load_program_data()
	_setup_room()
	_connect_signals()

func _load_program_data() -> void:
	if program_id.is_empty():
		push_warning("ProgramRoom: No program_id set!")
		return
	
	program_data = GameData.get_program(program_id)
	if program_data.is_empty():
		push_warning("ProgramRoom: Program not found: " + program_id)

func _setup_room() -> void:
	if program_data.is_empty():
		room_name_label.text = "Unknown Room"
		return
	
	# Set room name
	room_name_label.text = program_data.get("name", "Unknown Program")
	
	# Apply theme color to background
	if program_data.has("theme_color"):
		var theme_color: Color = program_data["theme_color"]
		background.color = theme_color.darkened(0.7)
		floor_rect.color = theme_color.darkened(0.5)
	
	# Create room content
	_create_room_content()

func _create_room_content() -> void:
	# Description display
	var desc_label = Label.new()
	desc_label.text = program_data.get("description", "")
	desc_label.position = Vector2(30, 40)
	desc_label.size = Vector2(260, 60)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.add_theme_font_size_override("font_size", 10)
	add_child(desc_label)
	
	# Degrees list
	var degrees = program_data.get("degrees", [])
	var y_offset = 110
	
	var degrees_title = Label.new()
	degrees_title.text = "📜 Degrees & Certificates:"
	degrees_title.position = Vector2(30, y_offset)
	degrees_title.add_theme_font_size_override("font_size", 11)
	degrees_title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	add_child(degrees_title)
	y_offset += 15
	
	for i in range(min(degrees.size(), 4)):  # Show up to 4 degrees
		var degree = degrees[i]
		var degree_label = Label.new()
		degree_label.text = "• " + degree.get("name", "")
		degree_label.position = Vector2(35, y_offset)
		degree_label.add_theme_font_size_override("font_size", 9)
		add_child(degree_label)
		y_offset += 12
	
	# Program lead info (if exists)
	if program_data.has("program_lead"):
		var lead = program_data["program_lead"]
		_create_npc_display(lead)

func _create_npc_display(person_data: Dictionary) -> void:
	var npc_container = Control.new()
	npc_container.position = Vector2(200, 50)
	
	# NPC "sprite" (emoji placeholder)
	var npc_icon = Label.new()
	npc_icon.text = "👨‍🏫"
	npc_icon.add_theme_font_size_override("font_size", 24)
	npc_container.add_child(npc_icon)
	
	# Name
	var name_label = Label.new()
	name_label.text = person_data.get("name", "")
	name_label.position = Vector2(0, 30)
	name_label.add_theme_font_size_override("font_size", 10)
	npc_container.add_child(name_label)
	
	# Title
	var title_label = Label.new()
	title_label.text = person_data.get("title", "")
	title_label.position = Vector2(0, 42)
	title_label.add_theme_font_size_override("font_size", 8)
	title_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	npc_container.add_child(title_label)
	
	add_child(npc_container)

func _connect_signals() -> void:
	if exit_area:
		exit_area.body_entered.connect(_on_exit_area_entered)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		exit_requested.emit()

func _on_exit_area_entered(body: Node2D) -> void:
	if body == player:
		exit_requested.emit()
