extends CharacterBody2D

# Player movement script following HeartBeast Action RPG tutorial conventions
# Adapted for Godot 4 and JagQuest (SWC Educational Game)

# Movement constants
const MAX_SPEED = 80
const ACCELERATION = 500
const FRICTION = 500

# Called every physics frame
func _physics_process(delta: float) -> void:
	# Get input vector for 8-directional movement
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()  # Normalize to prevent faster diagonal movement
	
	if input_vector != Vector2.ZERO:
		# Accelerate towards max speed
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		# Apply friction when not moving
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	# Move and handle collisions (Godot 4 style)
	move_and_slide()
