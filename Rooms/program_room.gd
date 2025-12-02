extends Node2D
class_name ProgramRoom

# Program Room - Interior view for each academic program
# Features: Zelda SNES-style 3D-ish perspective, program info, interactive elements

signal exit_requested
signal person_interacted(person_id: String)

# Room configuration
@export var program_id: String = ""
@export var room_theme_color: Color = Color.WHITE

# References
@onready var player: JaguarPlayer = $Player
@onready var room_background: Sprite2D = $Background
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
		return
	
	# Set room name
	if room_name_label:
		room_name_label.text = program_data.get("name", "Unknown Program")
	
	# Apply theme color
	if program_data.has("theme_color"):
		room_theme_color = program_data["theme_color"]
		_apply_theme_color()
	
	# Create interactive elements based on program
	_setup_room_elements()

func _apply_theme_color() -> void:
	# Apply theme color to UI elements
	pass  # Will be expanded with actual theming

func _setup_room_elements() -> void:
	# Create NPCs for program lead (if exists)
	if program_data.has("program_lead"):
		var lead = program_data["program_lead"]
		_create_npc(lead)
	
	# Create degree display stations
	var degrees = program_data.get("degrees", [])
	for i in range(degrees.size()):
		_create_degree_station(degrees[i], i)
	
	# Create info kiosk
	_create_info_kiosk()

func _create_npc(person_data: Dictionary) -> void:
	# Create an NPC that player can interact with
	var npc = Area2D.new()
	npc.name = "NPC_" + person_data.get("name", "Unknown").replace(" ", "_")
	npc.position = Vector2(200, 100)  # Position will vary by room layout
	
	# Collision
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 20
	collision.shape = shape
	npc.add_child(collision)
	
	# Sprite (placeholder)
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	npc.add_child(sprite)
	
	# Label
	var label = Label.new()
	label.text = person_data.get("name", "")
	label.position = Vector2(-40, -40)
	npc.add_child(label)
	
	# Store data
	npc.set_meta("person_data", person_data)
	
	# Connect interaction
	npc.input_event.connect(_on_npc_clicked.bind(npc))
	
	add_child(npc)

func _create_degree_station(degree_data: Dictionary, index: int) -> void:
	# Create a display showing degree info
	var station = Area2D.new()
	station.name = "Degree_" + str(index)
	
	# Position in a row
	var x_pos = 100 + (index % 3) * 100
	var y_pos = 200 + (index / 3) * 80
	station.position = Vector2(x_pos, y_pos)
	
	# Visual
	var label = Label.new()
	label.text = "📜 " + degree_data.get("name", "Degree")
	label.add_theme_font_size_override("font_size", 10)
	station.add_child(label)
	
	# Store URL for click
	station.set_meta("degree_url", degree_data.get("url", ""))
	
	add_child(station)

func _create_info_kiosk() -> void:
	# Central info display
	pass

func _connect_signals() -> void:
	if exit_area:
		exit_area.body_entered.connect(_on_exit_area_entered)

func _input(event: InputEvent) -> void:
	# Exit room with Escape
	if event.is_action_pressed("ui_cancel"):
		_exit_room()

func _on_exit_area_entered(body: Node2D) -> void:
	if body == player:
		_exit_room()

func _on_npc_clicked(viewport: Node, event: InputEvent, shape_idx: int, npc: Area2D) -> void:
	if event is InputEventMouseButton and event.pressed:
		var person_data = npc.get_meta("person_data")
		_show_person_info(person_data)

func _show_person_info(person_data: Dictionary) -> void:
	if info_panel:
		info_panel.visible = true
		# Update info panel content
		var name_label = info_panel.get_node_or_null("Name")
		if name_label:
			name_label.text = person_data.get("name", "")
		
		var title_label = info_panel.get_node_or_null("Title")
		if title_label:
			title_label.text = person_data.get("title", "")
		
		var contact_label = info_panel.get_node_or_null("Contact")
		if contact_label:
			contact_label.text = "📧 " + person_data.get("email", "") + "\n📞 " + person_data.get("phone", "")

func _exit_room() -> void:
	exit_requested.emit()

# Initialize room with specific program
func setup(p_program_id: String) -> void:
	program_id = p_program_id
	if is_inside_tree():
		_load_program_data()
		_setup_room()
