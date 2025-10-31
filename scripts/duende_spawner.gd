extends Node3D

@export var goblin_scenes: Array[PackedScene]
@export var player_path: NodePath
@export var radius_min: float = 12.0
@export var radius_max: float = 35.0
@export var spawn_every: float = 2.0
@export var batch: int = 2
@export var max_alive: int = 15
@export var height_probe: float = 100.0          

var _player: Node3D
var _timer: Timer

func _ready() -> void:
	randomize()

	if player_path != NodePath():
		_player = get_node(player_path) as Node3D
	else:
		_player = get_tree().get_first_node_in_group("player") as Node3D

	_timer = Timer.new()
	_timer.wait_time = spawn_every
	_timer.autostart = true
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)


func _on_timeout() -> void:
	if _player == null or !is_instance_valid(_player):
		return

	var vivos: int = get_tree().get_nodes_in_group("duende").size()
	var to_spawn: int = min(batch, max_alive - vivos)
	if to_spawn <= 0:
		return

	for i in range(to_spawn):
		_spawn_one()


func _spawn_one() -> void:
	if goblin_scenes.is_empty():
		return

	var scene: PackedScene = goblin_scenes[randi() % goblin_scenes.size()]
	var duende: Node3D = scene.instantiate() as Node3D
	duende.add_to_group("duende")

	var center: Vector3 = _player.global_transform.origin
	var angle: float = randf() * TAU
	var r: float = randf_range(radius_min, radius_max)
	var spawn_from: Vector3 = Vector3(
		center.x + cos(angle) * r,
		center.y + height_probe,
		center.z + sin(angle) * r
	)

	var to: Vector3 = spawn_from - Vector3.UP * (height_probe * 2.0)
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(spawn_from, to)

	var hit: Dictionary = space.intersect_ray(query)

	if hit.has("position"):
		var ground: Vector3 = (hit["position"] as Vector3) + Vector3.UP * 0.2
		duende.global_transform = Transform3D(Basis(), ground)
		add_child(duende)
	else:
		duende.queue_free()
