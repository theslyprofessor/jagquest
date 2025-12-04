extends CharacterBody2D
class_name JaguarPlayer

# JagQuest Player - The Jaguar navigator
# Supports keyboard (WASD/Arrows) and Option+Click navigation
# Features Zelda-style pulsating idle animation

# Movement constants (base values at zoom 1.0)
# Actual speed scales inversely with zoom so jaguar moves same % of viewport
const BASE_MAX_SPEED: float = 150.0
const BASE_ACCELERATION: float = 800.0
const BASE_FRICTION: float = 600.0

# =============================================================================
# MASTER BOUNDS - All viewport/camera/player limits derive from these
# =============================================================================
# Campus map SVG dimensions (from campus_map.svg - THE ONLY MAP FILE)
# SVG is 802.583 x 779.52 logical units
# Godot import scale TBD - will calculate from actual texture size at runtime
const SVG_WIDTH: float = 802.583
const SVG_HEIGHT: float = 779.52
# These will be updated based on actual Godot texture size
const PLAYABLE_WIDTH: float = SVG_WIDTH * 2.0   # 1605.166 (assume 2x for now)
const PLAYABLE_HEIGHT: float = SVG_HEIGHT * 2.0 # 1559.04 (assume 2x for now)

# UI bar is now in separate Control, not in SubViewport
# SubViewport is exactly 1200x900 - no subtraction needed

# Padding from edges for player movement
const PLAYER_PADDING: float = 10.0

# Derived player bounds
const MAP_MIN_X: float = PLAYER_PADDING
const MAP_MAX_X: float = PLAYABLE_WIDTH - PLAYER_PADDING
const MAP_MIN_Y: float = PLAYER_PADDING
const MAP_MAX_Y: float = PLAYABLE_HEIGHT - PLAYER_PADDING

# Navigation mode
enum NavMode { KEYBOARD, MOUSE }
var nav_mode: NavMode = NavMode.KEYBOARD
var mouse_target: Vector2 = Vector2.ZERO
var mouse_arrival_threshold: float = 8.0

# Animation
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera2D = $Camera2D
@onready var offscreen_indicator: Sprite2D = $OffscreenIndicator

# Direction facing (for sprite)
var facing_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false

# Zoom settings - derived from playable area and window size
# Window is set in project.godot (1200x900)
# MIN_CAMERA_ZOOM calculated at runtime to fit PLAYABLE_WIDTH x PLAYABLE_HEIGHT
const MAX_CAMERA_ZOOM: float = 4.0   # Close-up detail
const ZOOM_STEP: float = 0.15
var min_camera_zoom: float = 0.93    # Calculated in _ready()

# Jaguar size - maintains constant screen size regardless of zoom
# base_sprite_scale is the scale at zoom 1.0
# Actual scale = base_sprite_scale / camera.zoom to counter zoom effect
var base_sprite_scale: float = 0.15  # Set in _ready(), scale at zoom 1.0

# Camera panning (click-drag)
var is_panning: bool = false
var pan_start_mouse: Vector2 = Vector2.ZERO
var pan_start_camera: Vector2 = Vector2.ZERO

# Hover/tooltip system
signal hover_location_changed(location_data: Dictionary)
signal hover_cleared()

func _ready() -> void:
	# CRITICAL: Make sure player respects pause (for JagGenie)
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Set collision layer (player = layer 1)
	collision_layer = 1
	collision_mask = 2  # Collide with buildings/obstacles
	
	# Set camera limits to match playable area
	if camera:
		camera.limit_left = 0
		camera.limit_top = 0
		camera.limit_right = int(PLAYABLE_WIDTH)
		camera.limit_bottom = int(PLAYABLE_HEIGHT)
	
	# Start idle animation
	if animation_player:
		animation_player.play("idle")
	
	# Hide offscreen indicator initially
	if offscreen_indicator:
		offscreen_indicator.visible = false
	
	# Defer zoom calculation until viewport is ready
	call_deferred("_recalculate_zoom")

func _recalculate_zoom() -> void:
	# Calculate min zoom to fit playable area in viewport
	var viewport_size = get_viewport().get_visible_rect().size
	print("Player recalculating zoom with viewport size: ", viewport_size)
	
	if viewport_size.x < 10 or viewport_size.y < 10:
		# Viewport not ready yet, try again next frame
		await get_tree().process_frame
		_recalculate_zoom()
		return
	
	var zoom_to_fit_width = viewport_size.x / PLAYABLE_WIDTH
	var zoom_to_fit_height = viewport_size.y / PLAYABLE_HEIGHT
	min_camera_zoom = min(zoom_to_fit_width, zoom_to_fit_height)
	
	# Add 5% margin to ensure entire map is visible
	min_camera_zoom *= 0.95
	
	print("Min camera zoom: ", min_camera_zoom)
	
	# Set initial zoom to show entire map
	if camera:
		camera.zoom = Vector2(min_camera_zoom, min_camera_zoom)
	
	# Set jaguar base size - will be ~1/30th of viewport at zoom 1.0
	if sprite:
		var target_screen_size = viewport_size.x / 30.0
		var sprite_native_size = sprite.texture.get_width() if sprite.texture else 1000.0
		base_sprite_scale = target_screen_size / sprite_native_size
		_update_sprite_scale()

func _physics_process(delta: float) -> void:
	# Don't run physics when paused (for JagGenie)
	if get_tree().paused:
		return
	
	var input_vector = _get_input_vector()
	
	# Keyboard input takes priority
	if input_vector != Vector2.ZERO:
		nav_mode = NavMode.KEYBOARD
	
	match nav_mode:
		NavMode.KEYBOARD:
			_handle_keyboard_movement(input_vector, delta)
		NavMode.MOUSE:
			_handle_mouse_movement(delta)
	
	# Track if we're moving for animation
	var was_moving = is_moving
	is_moving = velocity.length() > 10
	
	# Switch animations when movement state changes
	if is_moving != was_moving:
		_update_animation()
	
	move_and_slide()
	
	# Clamp position to playable area (hard boundary)
	global_position.x = clamp(global_position.x, MAP_MIN_X, MAP_MAX_X)
	global_position.y = clamp(global_position.y, MAP_MIN_Y, MAP_MAX_Y)
	
	# Update offscreen indicator
	_update_offscreen_indicator()

func _get_input_vector() -> Vector2:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if input_vector != Vector2.ZERO:
		print("  -> RAW INPUT DETECTED: ", input_vector)
	
	return input_vector.normalized()

func _get_zoom_speed_multiplier() -> float:
	# At zoom 1.0, multiplier = 1.0 (base speed)
	# At zoom 2.0, multiplier = 0.5 (half speed, same % of viewport)
	# At zoom 0.5, multiplier = 2.0 (double speed, same % of viewport)
	if camera:
		return 1.0 / camera.zoom.x
	return 1.0

func _handle_keyboard_movement(input_vector: Vector2, delta: float) -> void:
	var speed_mult = _get_zoom_speed_multiplier()
	var max_speed = BASE_MAX_SPEED * speed_mult
	var acceleration = BASE_ACCELERATION * speed_mult
	var friction = BASE_FRICTION * speed_mult
	
	if input_vector != Vector2.ZERO:
		facing_direction = input_vector
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func _handle_mouse_movement(delta: float) -> void:
	var speed_mult = _get_zoom_speed_multiplier()
	var max_speed = BASE_MAX_SPEED * speed_mult
	var acceleration = BASE_ACCELERATION * speed_mult
	var friction = BASE_FRICTION * speed_mult
	
	# Clamp mouse target to playable bounds
	var clamped_target = Vector2(
		clamp(mouse_target.x, MAP_MIN_X, MAP_MAX_X),
		clamp(mouse_target.y, MAP_MIN_Y, MAP_MAX_Y)
	)
	
	var direction = (clamped_target - global_position).normalized()
	var distance = global_position.distance_to(clamped_target)
	
	if distance > mouse_arrival_threshold:
		facing_direction = direction
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if velocity.length() < 10:
			nav_mode = NavMode.KEYBOARD  # Return to keyboard mode when arrived

func _input(event: InputEvent) -> void:
	# Mouse button events
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Option+Click = walk to location
				if event.alt_pressed and not event.meta_pressed and not event.ctrl_pressed:
					mouse_target = get_global_mouse_position()
					nav_mode = NavMode.MOUSE
					get_viewport().set_input_as_handled()
				# Regular click = start panning
				else:
					is_panning = true
					pan_start_mouse = event.position
					pan_start_camera = camera.offset if camera else Vector2.ZERO
					get_viewport().set_input_as_handled()
			else:
				# Mouse released = stop panning
				is_panning = false
		
		# Note: Scroll wheel zoom is handled by main.gd and forwarded via zoom_camera_external()
		# This ensures it works properly through the SubViewport architecture
	
	# Keyboard zoom: R = zoom in, T = zoom out
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			_zoom_camera(true)  # Zoom in
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_T:
			_zoom_camera(false)  # Zoom out
			get_viewport().set_input_as_handled()
	
	# Mouse motion for panning
	if event is InputEventMouseMotion and is_panning and camera:
		var delta = event.position - pan_start_mouse
		# Invert and scale by zoom (smaller zoom = larger world movement)
		var pan_amount = -delta / camera.zoom.x
		camera.offset = pan_start_camera + pan_amount
		_clamp_camera_offset()
		get_viewport().set_input_as_handled()
	


func _zoom_camera(zoom_in: bool) -> void:
	if not camera:
		return
	
	var current_zoom = camera.zoom.x
	var new_zoom: float
	
	# Reversed: scroll up = zoom out, scroll down = zoom in
	if zoom_in:
		new_zoom = max(current_zoom - ZOOM_STEP, min_camera_zoom)  # zoom OUT
	else:
		new_zoom = min(current_zoom + ZOOM_STEP, MAX_CAMERA_ZOOM)  # zoom IN
	
	camera.zoom = Vector2(new_zoom, new_zoom)
	_clamp_camera_offset()  # Re-clamp offset after zoom change
	_update_sprite_scale()  # Keep jaguar same screen size

# External zoom function (called from main.gd for SubViewport input forwarding)
func zoom_camera_external(zoom_in: bool) -> void:
	print("zoom_camera_external called: zoom_in=", zoom_in)
	_zoom_camera(zoom_in)

func _update_sprite_scale() -> void:
	# Partially counter-scale sprite so it grows a little when zooming in
	# 0.0 = no compensation (normal zoom behavior - gets much bigger)
	# 1.0 = full compensation (constant screen size)
	# 0.7 = 70% compensation (gets a little bigger when zooming in)
	const ZOOM_COMPENSATION: float = 0.7
	
	if sprite and camera:
		# Blend between full zoom effect (1.0) and full compensation (1/zoom)
		var compensation_factor = 1.0 / camera.zoom.x
		var blended_factor = lerp(1.0, compensation_factor, ZOOM_COMPENSATION)
		var adjusted_scale = base_sprite_scale * blended_factor
		sprite.scale = Vector2(adjusted_scale, adjusted_scale)

func _clamp_camera_offset() -> void:
	if not camera:
		return
	
	# Calculate viewable area at current zoom
	var viewport_size = get_viewport().get_visible_rect().size
	var view_size = viewport_size / camera.zoom.x
	
	# Map bounds (camera limits)
	var map_width = camera.limit_right - camera.limit_left
	var map_height = camera.limit_bottom - camera.limit_top
	
	# If view is larger than map, center it (no panning needed)
	if view_size.x >= map_width:
		camera.offset.x = 0
	else:
		# Clamp offset so camera stays within map bounds
		var max_offset_x = (map_width - view_size.x) / 2
		camera.offset.x = clamp(camera.offset.x, -max_offset_x, max_offset_x)
	
	if view_size.y >= map_height:
		camera.offset.y = 0
	else:
		var max_offset_y = (map_height - view_size.y) / 2
		camera.offset.y = clamp(camera.offset.y, -max_offset_y, max_offset_y)

func _update_offscreen_indicator() -> void:
	if not offscreen_indicator or not camera:
		return
	
	# Get the visible rect in world coordinates
	var viewport_size = get_viewport().get_visible_rect().size
	var view_size = viewport_size / camera.zoom.x
	var camera_center = global_position + camera.offset
	
	var view_rect = Rect2(
		camera_center - view_size / 2,
		view_size
	)
	
	# Check if player is visible
	if view_rect.has_point(global_position):
		offscreen_indicator.visible = false
		return
	
	# Player is offscreen - show indicator at edge pointing to player
	offscreen_indicator.visible = true
	
	# Calculate direction from camera center to player
	var dir_to_player = (global_position - camera_center).normalized()
	
	# Calculate edge position (in local coords relative to player)
	var edge_margin = 30.0  # pixels from edge
	var half_view = view_size / 2 - Vector2(edge_margin, edge_margin)
	
	# Find intersection with viewport edge
	var indicator_pos = Vector2.ZERO
	if abs(dir_to_player.x) > abs(dir_to_player.y):
		# Hits left or right edge
		indicator_pos.x = sign(dir_to_player.x) * half_view.x
		indicator_pos.y = dir_to_player.y / abs(dir_to_player.x) * half_view.x
		indicator_pos.y = clamp(indicator_pos.y, -half_view.y, half_view.y)
	else:
		# Hits top or bottom edge
		indicator_pos.y = sign(dir_to_player.y) * half_view.y
		indicator_pos.x = dir_to_player.x / abs(dir_to_player.y) * half_view.y
		indicator_pos.x = clamp(indicator_pos.x, -half_view.x, half_view.x)
	
	# Position is relative to camera center, but indicator is child of player
	# So we need to offset by the camera offset
	offscreen_indicator.position = indicator_pos + camera.offset
	
	# Rotate to point toward player (from indicator's perspective, point outward)
	offscreen_indicator.rotation = dir_to_player.angle()

func _update_animation() -> void:
	if not animation_player:
		return
	
	if is_moving:
		if animation_player.current_animation != "walk":
			animation_player.play("walk")
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
	
	# Flip sprite for left/right movement
	if sprite:
		if abs(facing_direction.x) > 0.1:
			sprite.flip_h = facing_direction.x < 0

# Teleport to position (used by JagGenie)
func teleport_to(target: Vector2) -> void:
	# Clamp target to playable bounds
	global_position.x = clamp(target.x, MAP_MIN_X, MAP_MAX_X)
	global_position.y = clamp(target.y, MAP_MIN_Y, MAP_MAX_Y)
	velocity = Vector2.ZERO
	nav_mode = NavMode.KEYBOARD
