extends CharacterBody3D

const MAX_XROT_HEAD : float = 90.0

@export var walking_speed : float = 5.0
@export var sprinting_speed : float = 8.0
@export var crouching_speed : float = 3.0
@export var jump_velocity : float = 4.5

var current_speed = 5.0
var mouse_sensitivity : float = 0.15

@onready var cabeza: Node3D = $Cabeza

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _input(event: InputEvent) -> void:
	# Rotación de la cámara
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		cabeza.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		cabeza.rotation.x = clamp(cabeza.rotation.x, deg_to_rad(-MAX_XROT_HEAD), deg_to_rad(MAX_XROT_HEAD))

func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("sprint"):
		current_speed = sprinting_speed
	else:
		current_speed = walking_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()