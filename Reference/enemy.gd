extends CharacterBody3D

@export var approach_speed: float = 1.8    # velocidad cuando NO lo “ve”
@export var chase_speed: float = 4.5       # velocidad cuando SÍ lo ve (FOV)
@export var gravity: float = 9.8

@onready var fov_area = $enemy_FOV 
var player: Node3D = null
var chasing: bool = false

func _ready() -> void:
	add_to_group("enemy")

	# Conecta FOV si existe
	if fov_area:
		fov_area.body_entered.connect(_on_fov_enter)
		fov_area.body_exited.connect(_on_fov_exit)

	# ✅ Tomar referencia al Player desde el grupo (importante)
	player = get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		push_warning("Enemy: no encontré un nodo en el grupo 'player'. Asegúrate de añadir el Player al grupo.")

func _physics_process(delta: float) -> void:
	# gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# movimiento
	if player and is_instance_valid(player):
		if chasing:
			_chase_player(delta)
		else:
			_approach_player(delta)
	else:
		# si no hay player, detente
		velocity.x = move_toward(velocity.x, 0.0, approach_speed * delta)
		velocity.z = move_toward(velocity.z, 0.0, approach_speed * delta)

	move_and_slide()
	_check_collision_with_player()

# --- acercamiento constante ---
func _approach_player(delta: float) -> void:
	var dir := player.global_position - global_position
	dir.y = 0
	var len := dir.length()
	if len > 0.001:
		dir /= len
		velocity.x = dir.x * approach_speed
		velocity.z = dir.z * approach_speed
		look_at(global_position + dir, Vector3.UP)

# --- persecución al verlo ---
func _chase_player(delta: float) -> void:
	var dir := player.global_position - global_position
	dir.y = 0
	var len := dir.length()
	if len > 0.001:
		dir /= len
		velocity.x = dir.x * chase_speed
		velocity.z = dir.z * chase_speed
		look_at(global_position + dir, Vector3.UP)

# --- FOV entra/sale ---
func _on_fov_enter(body: Node) -> void:
	if body.is_in_group("player"):
		chasing = true

func _on_fov_exit(body: Node) -> void:
	if body.is_in_group("player"):
		chasing = false

# --- colisión con player = reinicio ---
func _check_collision_with_player() -> void:
	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var other := col.get_collider()
		if other and other.is_in_group("player"):
			get_tree().reload_current_scene()
