extends CharacterBody2D
class_name JaguarPlayer

# JagQuest Player - The Jaguar navigator
# Supports both keyboard (WASD/Arrows) and mouse-click navigation

# Movement constants
const MAX_SPEED: float = 120.0
const ACCELERATION: float = 600.0
const FRICTION: float = 500.0

# Navigation mode
enum NavMode { KEYBOARD, MOUSE }
var nav_mode: NavMode = NavMode.KEYBOARD
var mouse_target: Vector2 = Vector2.ZERO
var mouse_arrival_threshold: float = 8.0

# Animation
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Direction facing (for sprite)
var facing_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	# Set collision layer (player = layer 1)
	collision_layer = 1
	collision_mask = 2  # Collide with buildings/obstacles

func _physics_process(delta: float) -> void:
	var input_vector = _get_input_vector()
	
	# Keyboard input takes priority
	if input_vector != Vector2.ZERO:
		nav_mode = NavMode.KEYBOARD
	
	match nav_mode:
		NavMode.KEYBOARD:
			_handle_keyboard_movement(input_vector, delta)
		NavMode.MOUSE:
			_handle_mouse_movement(delta)
	
	_update_animation()
	move_and_slide()

func _get_input_vector() -> Vector2:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	return input_vector.normalized()

func _handle_keyboard_movement(input_vector: Vector2, delta: float) -> void:
	if input_vector != Vector2.ZERO:
		facing_direction = input_vector
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

func _handle_mouse_movement(delta: float) -> void:
	var direction = (mouse_target - global_position).normalized()
	var distance = global_position.distance_to(mouse_target)
	
	if distance > mouse_arrival_threshold:
		facing_direction = direction
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		if velocity.length() < 10:
			nav_mode = NavMode.KEYBOARD  # Return to keyboard mode when arrived

func _input(event: InputEvent) -> void:
	# Mouse click to set navigation target
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			mouse_target = get_global_mouse_position()
			nav_mode = NavMode.MOUSE

func _update_animation() -> void:
	# Determine animation based on facing direction and movement
	var is_moving = velocity.length() > 10
	
	# Simple 4-direction facing
	var anim_suffix = ""
	if abs(facing_direction.x) > abs(facing_direction.y):
		anim_suffix = "right" if facing_direction.x > 0 else "left"
	else:
		anim_suffix = "down" if facing_direction.y > 0 else "up"
	
	var anim_name = "walk_" + anim_suffix if is_moving else "idle_" + anim_suffix
	
	# Play animation if it exists
	if animation_player and animation_player.has_animation(anim_name):
		if animation_player.current_animation != anim_name:
			animation_player.play(anim_name)
	
	# Flip sprite for left/right (if using single sprite)
	if sprite:
		sprite.flip_h = facing_direction.x < 0

# Teleport to position (used by JagGenie)
func teleport_to(target: Vector2) -> void:
	global_position = target
	velocity = Vector2.ZERO
	nav_mode = NavMode.KEYBOARD
