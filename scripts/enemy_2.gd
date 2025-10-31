extends CharacterBody3D

@export var move_speed: float = 2.5
@export var chase_speed: float = 4.5
@export var gravity: float = 9.8

@onready var fov_area: Area3D = $enemy_FOV # tu campo de visión
var player: Node3D = null
var chasing: bool = false
var wander_dir: Vector3 = Vector3.ZERO
var wander_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	fov_area.body_entered.connect(_on_fov_enter)
	fov_area.body_exited.connect(_on_fov_exit)
	# Detectar colisión física con el Player
	$CollisionShape3D.disabled = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if chasing and player and is_instance_valid(player):
		_chase_player(delta)
	else:
		_wander_around(delta)

	move_and_slide()

	# Si choca con el jugador, reinicia escena
	_check_collision_with_player()

# --------------------------------------
# Movimiento aleatorio (rondar)
# --------------------------------------
func _wander_around(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0.0:
		wander_timer = randf_range(1.5, 3.0)
		var angle = randf() * TAU
		wander_dir = Vector3(cos(angle), 0, sin(angle))
	
	velocity.x = move_toward(velocity.x, wander_dir.x * move_speed, move_speed * delta)
	velocity.z = move_toward(velocity.z, wander_dir.z * move_speed, move_speed * delta)

	look_at(global_position + Vector3(wander_dir.x, 0, wander_dir.z))

# --------------------------------------
# Persecución
# --------------------------------------
func _chase_player(delta: float) -> void:
	var dir = (player.global_position - global_position)
	dir.y = 0
	dir = dir.normalized()
	
	velocity.x = dir.x * chase_speed
	velocity.z = dir.z * chase_speed
	
	look_at(global_position + dir)

# --------------------------------------
# Detectar entrada/salida del jugador en el FOV
# --------------------------------------
func _on_fov_enter(body: Node) -> void:
	if body.is_in_group("player"):
		player = body
		chasing = true

func _on_fov_exit(body: Node) -> void:
	if body == player:
		player = null
		chasing = false

# --------------------------------------
# Colisión directa con el Player = muerte
# --------------------------------------
func _check_collision_with_player() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body and body.is_in_group("player"):
			print("💀 Enemy collided with player — Restarting scene")
			_restart_scene()

# Reinicio del nivel
func _restart_scene() -> void:
	var scene_tree = get_tree()
	if scene_tree:
		scene_tree.reload_current_scene()
