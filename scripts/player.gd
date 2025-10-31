extends CharacterBody3D

@export var X_SENS: float = 0.005
@export var Y_SENS: float = 0.005

@export var WALKING_SPEED : float = 2.0
@export var SPRINT_SPEED : float = 5.0
@export var JUMP_VELOCITY : float = 3.0
@export var DUENDES: Array[Node] = []

@onready var neck = $neck
@onready var camera = $neck/Camera3D
@onready var camera_ray: RayCast3D = $RayCast3D

@onready var crt_shader: ColorRect = $"../shaders/crt"
@onready var camera_info: Node2D = $"../camera_info"

var camera_open = false
var current_speed = WALKING_SPEED

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action_pressed("player_use_camera"):
		camera_open = !camera_open
		crt_shader.visible = camera_open
		camera_info.visible = camera_open
		
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
	
	if Input.is_action_just_pressed("player_sprint"):
		current_speed = SPRINT_SPEED
	elif Input.is_action_just_released("player_sprint"):
		current_speed = WALKING_SPEED
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	# Saltar
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if camera_open:
		camera_ray.enabled = true
		
	if camera_ray.get_collider():
		var rayado = camera_ray.get_collider()
		if rayado in DUENDES:
			print('duende')
	
	move_and_slide()
