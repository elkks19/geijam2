extends Node3D

# ---------- Config general ----------
@export var goblin_scenes: Array[PackedScene]
@export var player_path: NodePath
@export var radius_min: float = 12.0
@export var radius_max: float = 35.0
@export var spawn_every: float = 2.0
@export var batch: int = 2
@export var max_alive: int = 15
@export var height_probe: float = 100.0

# ---------- Prueba: spawns delante de la cámara ----------
@export var camera_path: NodePath                       # arrastra tu Camera3D aquí
@export var test_burst_count: int = 20                   # cuántos spawnear por burst
@export var front_distance: float = 10.0                 # a qué distancia delante de la cámara
@export var front_spread_x: float = 8.0                  # ancho del “rectángulo” (eje X de la cámara)
@export var front_spread_y: float = 4.0                  # alto del “rectángulo” (eje Y de la cámara)

var _player: Node3D
var _camera: Camera3D
var _timer: Timer

func _ready() -> void:
	randomize()

	# Player
	if player_path != NodePath():
		_player = get_node(player_path) as Node3D
	else:
		_player = get_tree().get_first_node_in_group("player") as Node3D

	# Cámara
	if camera_path != NodePath():
		_camera = get_node(camera_path) as Camera3D

	# Timer de spawns normales
	_timer = Timer.new()
	_timer.wait_time = spawn_every
	_timer.autostart = true
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)


func _process(_delta: float) -> void:
	# Presiona la acción "spawn_test" para spawnear muchos delante de la cámara
	if Input.is_action_just_pressed("spawn_test"):
		_spawn_burst_in_front()


# ---------- Spawn normal alrededor del player ----------
func _on_timeout() -> void:
	if _player == null or !is_instance_valid(_player):
		return

	var vivos: int = get_tree().get_nodes_in_group("duende").size()
	var to_spawn: int = min(batch, max_alive - vivos)
	if to_spawn <= 0:
		return

	for i in range(to_spawn):
		_spawn_one_ring()


func _spawn_one_ring() -> void:
	if goblin_scenes.is_empty():
		return

	var scene: PackedScene = goblin_scenes[randi() % goblin_scenes.size()]
	var duende: Node3D = scene.instantiate() as Node3D
	duende.add_to_group("duende")

	# punto aleatorio alrededor del Player
	var center: Vector3 = _player.global_transform.origin
	var angle: float = randf() * TAU
	var r: float = randf_range(radius_min, radius_max)
	var spawn_from: Vector3 = Vector3(
		center.x + cos(angle) * r,
		center.y + height_probe,
		center.z + sin(angle) * r
	)

	_place_on_ground_or_free(duende, spawn_from)


# ---------- Burst delante de la cámara ----------
func _spawn_burst_in_front() -> void:
	if _camera == null or !is_instance_valid(_camera):
		push_warning("Camera3D no asignada. Arrastra tu cámara a 'camera_path'.")
		return
	if goblin_scenes.is_empty():
		return

	for i in range(test_burst_count):
		var scene: PackedScene = goblin_scenes[randi() % goblin_scenes.size()]
		var duende: Node3D = scene.instantiate() as Node3D
		duende.add_to_group("duende")

		# Base: un punto delante de la cámara
		var cam_x: Vector3 = _camera.global_transform.basis.x
		var cam_y: Vector3 = _camera.global_transform.basis.y
		var cam_fwd: Vector3 = -_camera.global_transform.basis.z  # forward en Godot es -Z
		var origin: Vector3 = _camera.global_transform.origin + cam_fwd * front_distance

		# Dispersión rectangular delante de la cámara (spread en X/Y de la cámara)
		var offset: Vector3 = cam_x * randf_range(-front_spread_x, front_spread_x) \
							+ cam_y * randf_range(-front_spread_y, front_spread_y)

		var spawn_from: Vector3 = origin + offset + Vector3.UP * height_probe
		_place_on_ground_or_free(duende, spawn_from)


# ---------- Util: raycast hacia abajo y colocar ----------
func _place_on_ground_or_free(duende: Node3D, spawn_from: Vector3) -> void:
	var to: Vector3 = spawn_from - Vector3.UP * (height_probe * 2.0)
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(spawn_from, to)
	# query.collision_mask = 0xFFFFFFFF  # ajusta si usas capas

	var hit: Dictionary = space.intersect_ray(query)
	if hit.has("position"):
		var ground: Vector3 = (hit["position"] as Vector3) + Vector3.UP * 0.2
		duende.global_transform = Transform3D(Basis(), ground)
		add_child(duende)
	else:
		duende.queue_free()
