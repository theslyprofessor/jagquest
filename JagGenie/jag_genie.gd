extends CanvasLayer
class_name JagGenie

# JagGenie - Fuzzy finder teleport system
# Press Tab/G to open, type to search, select to view info and teleport

signal location_selected(entity_id: String, entity_type: String)
signal closed

@onready var panel: Panel = $Panel
@onready var search_input: LineEdit = $Panel/VBox/SearchInput
@onready var results_list: ItemList = $Panel/VBox/ResultsList
@onready var info_panel: Panel = $Panel/VBox/InfoPanel
@onready var info_name: Label = $Panel/VBox/InfoPanel/VBox/InfoName
@onready var info_type: Label = $Panel/VBox/InfoPanel/VBox/InfoType
@onready var info_description: RichTextLabel = $Panel/VBox/InfoPanel/VBox/InfoDescription
@onready var teleport_button: Button = $Panel/VBox/InfoPanel/VBox/TeleportButton

var GameData = preload("res://Data/game_data.gd")
var current_results: Array = []
var selected_entity: Dictionary = {}

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # Work even when game is paused
	_connect_signals()

func _connect_signals() -> void:
	search_input.text_changed.connect(_on_search_changed)
	results_list.item_selected.connect(_on_result_selected)
	results_list.item_activated.connect(_on_result_activated)
	teleport_button.pressed.connect(_on_teleport_pressed)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_down"):
		_navigate_results(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_navigate_results(-1)
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_accept") and results_list.get_selected_items().size() > 0:
		_on_result_activated(results_list.get_selected_items()[0])
		get_viewport().set_input_as_handled()

func open() -> void:
	visible = true
	search_input.text = ""
	search_input.grab_focus()
	_populate_initial_results()
	get_tree().paused = true

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
	results_list.clear()
	
	for entity in current_results:
		var display_text = _get_display_text(entity)
		results_list.add_item(display_text)
	
	if results_list.item_count > 0:
		results_list.select(0)
		_on_result_selected(0)

func _get_display_text(entity: Dictionary) -> String:
	var prefix = ""
	match entity.get("search_type", ""):
		"building":
			prefix = "🏛️ "
		"program":
			prefix = "📚 "
		"person":
			prefix = "👤 "
	
	return prefix + entity.get("name", "Unknown")

func _navigate_results(direction: int) -> void:
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
	_on_teleport_pressed()

func _update_info_panel() -> void:
	if selected_entity.is_empty():
		info_panel.visible = false
		return
	
	info_panel.visible = true
	info_name.text = selected_entity.get("name", "Unknown")
	
	var type_text = ""
	match selected_entity.get("search_type", ""):
		"building":
			type_text = "📍 Building"
		"program":
			var building_id = selected_entity.get("building_id", "")
			var building = GameData.get_building(building_id)
			type_text = "📚 Program in " + building.get("name", "Unknown")
		"person":
			type_text = "👤 " + selected_entity.get("title", "Staff")
	
	info_type.text = type_text
	
	var description = selected_entity.get("description", "")
	if selected_entity.get("search_type") == "program":
		var degrees = selected_entity.get("degrees", [])
		if degrees.size() > 0:
			description += "\n\n[b]Degrees:[/b]\n"
			for degree in degrees:
				description += "• " + degree.get("name", "") + "\n"
	elif selected_entity.get("search_type") == "person":
		description = "📧 " + selected_entity.get("email", "N/A")
		description += "\n📞 " + selected_entity.get("phone", "N/A")
		description += "\n🚪 Office: " + selected_entity.get("office", "N/A")
	
	info_description.text = description

func _on_teleport_pressed() -> void:
	if selected_entity.is_empty():
		return
	
	var entity_id = selected_entity.get("id", "")
	var entity_type = selected_entity.get("search_type", "")
	
	location_selected.emit(entity_id, entity_type)
	close()
