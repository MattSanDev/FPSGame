extends CharacterBody3D

const MAX_XROT_HEAD : float = 90.0

# Speed vars
@export var walking_speed : float = 5.0
@export var sprinting_speed : float = 8.0
@export var crouching_speed : float = 3.0
@export var jump_velocity : float = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_speed = 5.0
var mouse_sensitivity : float = 0.15
var direction : Vector3 = Vector3.ZERO

var movement_lerp_speed : float = 10.0
var is_crouching : bool = false
var is_sprinting : bool = false

var crouch_depth : float = 0.6

@onready var cabeza: Node3D = $Cabeza
@onready var collider: CollisionShape3D = $Collider
@onready var ray_cast_3d: RayCast3D = $RayCast3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _input(event: InputEvent) -> void:
	# Rotación de la cámara
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		cabeza.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		cabeza.rotation.x = clamp(cabeza.rotation.x, deg_to_rad(-MAX_XROT_HEAD), deg_to_rad(MAX_XROT_HEAD))


func _physics_process(delta: float) -> void:
	process_movement(delta)


func process_movement(delta : float)-> void:
	is_crouching = Input.is_action_pressed("crouch")
	is_sprinting = Input.is_action_pressed("sprint")
	
	# Crouching
	if is_crouching:
		current_speed = crouching_speed
		cabeza.position.y = lerp(cabeza.position.y, 1.8, delta * movement_lerp_speed)
		collider.shape.height = lerp(collider.shape.height, 1.0, delta * movement_lerp_speed)
	# Standing
	elif not ray_cast_3d.is_colliding():
		cabeza.position.y = lerp(cabeza.position.y, 1.8, delta * movement_lerp_speed)
		collider.shape.height = lerp(collider.shape.height, 2.0, delta * movement_lerp_speed)
		# Sprinting
		if  is_sprinting and not is_crouching:
			current_speed = sprinting_speed
		# Walking
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
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * movement_lerp_speed)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
