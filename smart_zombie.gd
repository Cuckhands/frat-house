extends CharacterBody3D

@export var movement_speed: float = 1.0
@export var detection_radius: float = 30.0

@export var booze_hit: float = 0.02
@export var hit_range: float = 1.0

var health: float = 100.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player = $/root/Game/TestWorld/Player
@onready var hurt_timer: Timer = $HurtTimer # Prevents hurt spam
@onready var mesh: MeshInstance3D = $MeshInstance3D
var zb_tex: StandardMaterial3D = preload("res://zombie.tres")
var hurt_tex: StandardMaterial3D = preload("res://hurt.tres")

func _ready():
	mesh.set_surface_override_material(0, zb_tex)
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 1.0

	# Make sure to not await during _ready.
	actor_setup.call_deferred()

func damage(health_loss: float):
	if hurt_timer.is_stopped():
		hurt_timer.start()
		health -= health_loss
		mesh.set_surface_override_material(0, hurt_tex)
		print(health)
		if health <= 0:
			print("Zombie died")
			queue_free()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_random_movement_target(20.0)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func set_random_movement_target(max_distance: float):
	var offset = Vector3(
		randf_range(-max_distance, max_distance), 
		0, 
		randf_range(-max_distance, max_distance)
	)
	set_movement_target(global_position + offset)

func distance_to_player() -> float:
	return global_position.distance_to(player.position)

func _physics_process(delta):
	# Update target to player's position when near
	var dist = distance_to_player()
	if dist <= detection_radius:
		set_movement_target(player.position)
		if dist < hit_range:
			# TODO: sober up 0.02 and stop hitting every frame
			player.sober_up(0.02 * delta)
			print(player.bac)

	if navigation_agent.is_navigation_finished():
		# Choose a new spot to wander to
		set_random_movement_target(10.0)
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()

func _on_hurt_timer_timeout() -> void:
	mesh.set_surface_override_material(0, zb_tex)
