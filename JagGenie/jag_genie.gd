extends CanvasLayer
class_name JagGenie

# JagGenie - Fuzzy finder teleport/navigation system
# Press Tab/G to open, type to search, select to view info
# Buildings = Navigate in overworld
# Programs/People = Teleport inside room

signal location_selected(entity_id: String, entity_type: String, action_type: int)
signal navigate_to(position: Vector2)
signal closed

# Node references - will be fetched safely
var panel: Panel
var search_input: LineEdit
var results_list: ItemList
var info_panel: Panel
var info_name: Label
var info_type: Label
var info_description: RichTextLabel
var action_button: Button

# GameData is an autoload singleton - access directly without preload
var current_results: Array = []
var selected_entity: Dictionary = {}

# Icon prefixes for different entity types
const ICONS = {
	"building": "🏛️",
	"program": "📚",
	"person": "👤",
	"resource": "🔗",
	"department": "🏫"
}

func _ready() -> void:
	_get_node_references()
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_connect_signals()

func _get_node_references() -> void:
	panel = get_node_or_null("Panel")
	search_input = get_node_or_null("Panel/VBox/SearchInput")
	results_list = get_node_or_null("Panel/VBox/ResultsList")
	info_panel = get_node_or_null("Panel/VBox/InfoPanel")
	info_name = get_node_or_null("Panel/VBox/InfoPanel/VBox/InfoName")
	info_type = get_node_or_null("Panel/VBox/InfoPanel/VBox/InfoType")
	info_description = get_node_or_null("Panel/VBox/InfoPanel/VBox/InfoDescription")
	action_button = get_node_or_null("Panel/VBox/InfoPanel/VBox/TeleportButton")

func _connect_signals() -> void:
	if search_input:
		search_input.text_changed.connect(_on_search_changed)
	if results_list:
		results_list.item_selected.connect(_on_result_selected)
		results_list.item_activated.connect(_on_result_activated)
	if action_button:
		action_button.pressed.connect(_on_action_pressed)
	if info_description:
		info_description.meta_clicked.connect(_on_meta_clicked)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	# Only respond to specific keys in JagGenie to avoid conflicts with typing
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				close()
				get_viewport().set_input_as_handled()
			KEY_DOWN:
				_navigate_results(1)
				get_viewport().set_input_as_handled()
			KEY_UP:
				_navigate_results(-1)
				get_viewport().set_input_as_handled()
			KEY_ENTER:
				if results_list and results_list.get_selected_items().size() > 0:
					_on_result_activated(results_list.get_selected_items()[0])
					get_viewport().set_input_as_handled()

func open() -> void:
	visible = true
	if search_input:
		search_input.text = ""
	_populate_initial_results()
	get_tree().paused = true
	# Defer focus grab to ensure UI is ready
	await get_tree().process_frame
	if search_input:
		search_input.grab_focus()

func close() -> void:
	visible = false
	selected_entity = {}
	get_tree().paused = false
	closed.emit()

func _populate_initial_results() -> void:
	current_results = GameData.get_all_entities()
	_update_results_display()

func _on_search_changed(new_text: String) -> void:
	if new_text.is_empty():
		_populate_initial_results()
	else:
		current_results = GameData.fuzzy_search(new_text)
		_update_results_display()

func _update_results_display() -> void:
	if not results_list:
		return
	
	results_list.clear()
	
	for entity in current_results:
		var display_text = _get_display_text(entity)
		results_list.add_item(display_text)
	
	if results_list.item_count > 0:
		results_list.select(0)
		_on_result_selected(0)

func _get_display_text(entity: Dictionary) -> String:
	var search_type = entity.get("search_type", "")
	var prefix = ICONS.get(search_type, "")
	var name = entity.get("name", "Unknown")
	
	# Add subtitle for context
	var subtitle = ""
	match search_type:
		"program":
			subtitle = " (" + entity.get("department", "") + ")"
		"person":
			subtitle = " - " + entity.get("title", "")
		"building":
			var grid = entity.get("grid_location", "")
			if not grid.is_empty():
				subtitle = " [" + grid + "]"
	
	return prefix + " " + name + subtitle

func _navigate_results(direction: int) -> void:
	if not results_list:
		return
	
	var current = results_list.get_selected_items()
	if current.is_empty():
		if results_list.item_count > 0:
			results_list.select(0)
			_on_result_selected(0)
		return
	
	var new_index = current[0] + direction
	new_index = clamp(new_index, 0, results_list.item_count - 1)
	results_list.select(new_index)
	results_list.ensure_current_is_visible()
	_on_result_selected(new_index)

func _on_result_selected(index: int) -> void:
	if index < 0 or index >= current_results.size():
		return
	
	selected_entity = current_results[index]
	_update_info_panel()

func _on_result_activated(index: int) -> void:
	_on_action_pressed()

func _update_info_panel() -> void:
	if selected_entity.is_empty():
		if info_panel:
			info_panel.visible = false
		return
	
	if info_panel:
		info_panel.visible = true
	
	if info_name:
		info_name.text = selected_entity.get("name", "Unknown")
	
	var search_type = selected_entity.get("search_type", "")
	var action_type = selected_entity.get("action_type", 0)
	
	# Build type/location text
	var type_text = ""
	match search_type:
		"building":
			var grid = selected_entity.get("grid_location", "")
			type_text = "📍 Building"
			if not grid.is_empty():
				type_text += " • Grid " + grid
		"program":
			var building_id = selected_entity.get("building_id", "")
			var building = GameData.get_building(building_id)
			var dept = selected_entity.get("department", "")
			type_text = "📚 " + dept + " Department"
			if not building.is_empty():
				type_text += " • " + building.get("name", "")
		"person":
			type_text = "👤 " + selected_entity.get("title", "Staff")
			var office = selected_entity.get("office", "")
			if not office.is_empty():
				type_text += " • Office " + office
		"resource":
			type_text = "🔗 Student Resource"
	
	if info_type:
		info_type.text = type_text
	
	# Build description with rich text
	var description = selected_entity.get("description", "")
	
	# Add degrees/awards for programs
	if search_type == "program":
		var catalog_pages = selected_entity.get("catalog_pages", [])
		if catalog_pages.size() > 0:
			description += "\n\n[b]Available Awards (" + str(catalog_pages.size()) + "):[/b]\n"
			for page in catalog_pages:
				var type_badge = "[color=#4a9]AS[/color]" if page.get("type") == "Associate" else "[color=#a94]Cert[/color]"
				description += "• " + type_badge + " " + page.get("name", "") + "\n"
		
		# Add program lead if exists
		var lead = selected_entity.get("program_lead", null)
		if lead != null:
			description += "\n[b]Program Lead:[/b] " + lead.get("name", "")
			description += "\n📧 " + lead.get("email", "")
			description += " • 📞 " + lead.get("phone", "")
	
	# Add contact info for people
	elif search_type == "person":
		description = "[b]Contact Information[/b]\n"
		var email_url = selected_entity.get("email_url", "")
		if email_url and not email_url.is_empty():
			description += "📧 [url=" + email_url + "]Contact via SWC Portal[/url]\n"
		else:
			description += "📧 N/A\n"
		description += "📞 " + selected_entity.get("phone", "N/A") + "\n"
		description += "🚪 Office: " + selected_entity.get("office", "N/A")
	
	if info_description:
		info_description.text = description
	
	# Update action button based on action type
	if action_button:
		match action_type:
			GameData.ActionType.NAVIGATE:
				action_button.text = "🧭 Navigate Here"
			GameData.ActionType.TELEPORT:
				action_button.text = "🚀 Enter Room"
			GameData.ActionType.SHOW_INFO:
				action_button.text = "🔗 View Details"
			_:
				action_button.text = "🚀 Go"

func _on_action_pressed() -> void:
	if selected_entity.is_empty():
		return
	
	var entity_id = selected_entity.get("id", "")
	var search_type = selected_entity.get("search_type", "")
	var action_type = selected_entity.get("action_type", GameData.ActionType.NAVIGATE)
	
	# Emit appropriate signal based on action type
	match action_type:
		GameData.ActionType.NAVIGATE:
			# For buildings, navigate in overworld
			var position = selected_entity.get("map_position", Vector2.ZERO)
			navigate_to.emit(position)
		GameData.ActionType.TELEPORT:
			# For programs/people, teleport into room
			location_selected.emit(entity_id, search_type, action_type)
		GameData.ActionType.SHOW_INFO:
			# For resources, just show info (maybe open URL)
			var url = selected_entity.get("url", "")
			if not url.is_empty():
				OS.shell_open(url)
	
	close()

func _on_meta_clicked(meta: String) -> void:
	# Handle clicking links in the info description (like email URLs)
	OS.shell_open(meta)
