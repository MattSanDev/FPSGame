extends CharacterBody3D

const MAX_XROT_HEAD : float = 90.0

# Speed vars
@export var walking_speed : float = 5.0
@export var jump_velocity : float = 3.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_speed = 5.0
var mouse_sensitivity : float = 0.15
var direction : Vector3 = Vector3.ZERO

var movement_lerp_speed : float = 10.0

@onready var cabeza: Node3D = $Cabeza

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# Rotación de la cámara
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		cabeza.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		cabeza.rotation.x = clamp(cabeza.rotation.x, deg_to_rad(-MAX_XROT_HEAD), deg_to_rad(MAX_XROT_HEAD))


func _physics_process(delta: float) -> void:
	process_movement(delta)


func process_movement(delta : float)-> void:
		
	current_speed = walking_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * movement_lerp_speed)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
