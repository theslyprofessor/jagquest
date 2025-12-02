extends Node2D
class_name ProgramRoom

# Program Room - Interior view for each academic program
# Features:
# - Program Lead NPC at front (click for contact modal)
# - Catalog page icons (AS/Certificate clickables)
# - Program page link
# - Department subtitle

signal exit_requested

# Room configuration
@export var program_id: String = ""

# References - using get_node_or_null for safety
var background: ColorRect
var floor_tiles: ColorRect
var wall_top: ColorRect
var room_title: Label
var dept_subtitle: Label
var description_label: Label
var catalog_container: HBoxContainer
var npc_container: Control
var npc_sprite: Sprite2D
var npc_name: Label
var npc_title: Label
var npc_button: Button
var modal_panel: Panel
var modal_title: Label
var modal_content: RichTextLabel
var modal_close: Button
var exit_button: Button
var program_page_button: Button

# Room data (GameData is an autoload singleton)
var program_data: Dictionary = {}

func _ready() -> void:
	_get_node_references()
	_load_program_data()
	_setup_room()
	_create_catalog_icons()
	_setup_npc()
	_connect_signals()
	_hide_modal()

func _get_node_references() -> void:
	background = get_node_or_null("Background")
	floor_tiles = get_node_or_null("FloorTiles")
	wall_top = get_node_or_null("WallTop")
	room_title = get_node_or_null("UI/TopBar/RoomTitle")
	dept_subtitle = get_node_or_null("UI/TopBar/DeptSubtitle")
	description_label = get_node_or_null("UI/DescriptionPanel/Description")
	catalog_container = get_node_or_null("UI/CatalogContainer")
	npc_container = get_node_or_null("NPCArea")
	npc_sprite = get_node_or_null("NPCArea/NPCSprite")
	npc_name = get_node_or_null("NPCArea/NPCName")
	npc_title = get_node_or_null("NPCArea/NPCTitle")
	npc_button = get_node_or_null("NPCArea/NPCButton")
	modal_panel = get_node_or_null("UI/ModalPanel")
	modal_title = get_node_or_null("UI/ModalPanel/VBox/ModalTitle")
	modal_content = get_node_or_null("UI/ModalPanel/VBox/ModalContent")
	modal_close = get_node_or_null("UI/ModalPanel/VBox/ModalClose")
	exit_button = get_node_or_null("UI/ExitButton")
	program_page_button = get_node_or_null("UI/ProgramPageButton")

func _load_program_data() -> void:
	if program_id.is_empty():
		push_warning("ProgramRoom: No program_id set!")
		return
	
	program_data = GameData.get_program(program_id)
	if program_data.is_empty():
		push_warning("ProgramRoom: Program not found: " + program_id)

func _setup_room() -> void:
	if program_data.is_empty():
		if room_title:
			room_title.text = "Unknown Room"
		return
	
	# Set room title
	if room_title:
		room_title.text = program_data.get("name", "Unknown Program")
	
	# Set department subtitle
	if dept_subtitle:
		var dept = program_data.get("department", "")
		dept_subtitle.text = dept + " Department"
	
	# Set description
	if description_label:
		description_label.text = program_data.get("description", "")
	
	# Apply theme color
	if program_data.has("theme_color"):
		var theme_color: Color = program_data["theme_color"]
		if wall_top:
			wall_top.color = theme_color.darkened(0.6)
		if floor_tiles:
			floor_tiles.color = theme_color.darkened(0.4)
		if background:
			background.color = theme_color.darkened(0.8)

func _create_catalog_icons() -> void:
	if not catalog_container:
		return
	
	# Clear existing catalog buttons
	for child in catalog_container.get_children():
		child.queue_free()
	
	var catalog_pages = program_data.get("catalog_pages", [])
	
	for page in catalog_pages:
		var btn = Button.new()
		var page_type = page.get("type", "")
		var page_name = page.get("name", "")
		var page_url = page.get("url", "")
		
		# Style based on type
		if page_type == "Associate":
			btn.text = "AS: " + page_name
			btn.add_theme_color_override("font_color", Color(0.3, 0.7, 0.4))
		else:
			btn.text = "Cert: " + page_name
			btn.add_theme_color_override("font_color", Color(0.8, 0.6, 0.2))
		
		btn.tooltip_text = "View catalog page: " + page_name
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		
		# Connect to open URL
		var url_copy = page_url  # Capture for lambda
		btn.pressed.connect(func(): _open_catalog_page(page_name, url_copy))
		
		catalog_container.add_child(btn)

func _setup_npc() -> void:
	var lead = program_data.get("program_lead", null)
	
	if lead == null:
		# No program lead - hide NPC area
		if npc_container:
			npc_container.visible = false
		return
	
	if npc_container:
		npc_container.visible = true
	if npc_name:
		npc_name.text = lead.get("name", "Program Lead")
	if npc_title:
		npc_title.text = lead.get("title", "")
	if npc_button:
		npc_button.text = "Talk"
		npc_button.set_meta("lead_data", lead)

func _connect_signals() -> void:
	# NPC button
	if npc_button:
		npc_button.pressed.connect(_on_npc_clicked)
	
	# Modal close
	if modal_close:
		modal_close.pressed.connect(_hide_modal)
	
	# Exit button
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	
	# Program page button
	if program_page_button:
		program_page_button.pressed.connect(_on_program_page_pressed)
	
	# Modal content URL clicks
	if modal_content:
		modal_content.meta_clicked.connect(_on_modal_content_meta_clicked)

func _input(event: InputEvent) -> void:
	# ESC to close modal or exit room
	if event.is_action_pressed("ui_cancel"):
		if modal_panel and modal_panel.visible:
			_hide_modal()
		else:
			exit_requested.emit()

func _on_npc_clicked() -> void:
	if not npc_button:
		return
	var lead = npc_button.get_meta("lead_data", {})
	if lead.is_empty():
		return
	
	_show_contact_modal(lead)

func _show_contact_modal(person: Dictionary) -> void:
	if not modal_panel:
		return
	
	modal_panel.visible = true
	
	if modal_title:
		modal_title.text = person.get("name", "Contact")
	
	if modal_content:
		var content = "[b]" + person.get("title", "") + "[/b]\n\n"
		content += "Email: " + person.get("email", "N/A") + "\n"
		content += "Phone: " + person.get("phone", "N/A") + "\n"
		content += "Office: " + person.get("office", "N/A") + "\n\n"
		
		var contact_url = person.get("contact_url", "")
		if not contact_url.is_empty():
			content += "[url=" + contact_url + "]View Full Profile[/url]"
		
		modal_content.text = content

func _hide_modal() -> void:
	if modal_panel:
		modal_panel.visible = false

func _open_catalog_page(_page_name: String, url: String) -> void:
	if not url.is_empty():
		OS.shell_open(url)

func _on_exit_pressed() -> void:
	exit_requested.emit()

func _on_program_page_pressed() -> void:
	var url = program_data.get("program_page", "")
	if not url.is_empty():
		OS.shell_open(url)

func _on_modal_content_meta_clicked(meta) -> void:
	OS.shell_open(str(meta))
