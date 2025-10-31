extends CharacterBody3D

@export var X_SENS: float = 0.005
@export var Y_SENS: float = 0.005

@export var SPEED : float = 2.0
@export var JUMP_VELOCITY : float = 3.0
@export var KNOCKBACK_MULTIPLIER : float = 8.0
@export var ATTACK_RANGE : float = 1.0
@export var LERP_VAL: float = 0.15
@export var HEALTH: float = 100.0

@onready var neck = $neck
@onready var camera = $neck/Camera3D

@onready var color: ColorRect = $"../SHADERS/ColorRect"



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action_pressed("player_use_camera"):
		color.visible =! color.visible
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * Y_SENS)
			camera.rotate_x(-event.relative.y * X_SENS)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-30), deg_to_rad(60))

var direction
func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Manejar movimiento
	var input_dir = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Saltar
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()
