extends RigidBody3D

@onready var neck_pivot: Node3D = $NeckPivot
@onready var camera: Camera3D = $NeckPivot/Camera3D
@onready var melee_anim: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area3D = $NeckPivot/Camera3D/Hitbox
@onready var hud: Control = $HUD
@onready var jump_timer: Timer = $JumpTimer

@export var jump_force: float = 150.0
@export var mouse_sens: float = 0.001
# Gives roughly 20 seconds
@export var sober_rate: float = 0.002
var bac: float = 0.04
const MAX_BAC: float = 0.21
const MOVE_FORCE: float = 1000.0
var twist_input: float = 0.0 # For horizontal camera motion
var pitch_input: float = 0.0 # For vertical camera motion
var attack_dmg: float = 25.0

# Runs at initialization
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Runs every frame; delta represents the elapsed time since the last frame
func _process(delta: float) -> void:
	var input := Vector3.ZERO
	input.x = Input.get_axis("mv_left", "mv_right")
	input.z = Input.get_axis("mv_forward", "mv_backward")
	apply_central_force(neck_pivot.basis * input.normalized() * delta *
		(MOVE_FORCE * 1.5 if Input.is_action_pressed("sprint") else MOVE_FORCE))
	
	if Input.is_action_just_pressed("jump") and jump_timer.is_stopped():
		apply_central_force(Vector3.UP * jump_force)
		jump_timer.start()
	
	handle_melee()
	
	# DEBUG PURPOSES
	#if Input.is_action_just_pressed("ui_page_up"):
		#drink_booze(0.02)
	#if Input.is_action_just_pressed("ui_page_down"):
		#sober_up(0.04)
	
	# Controls camera motion
	neck_pivot.rotate_y(twist_input)
	camera.rotate_x(pitch_input)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	twist_input = 0.0
	pitch_input = 0.0
	
	# BAC goes down on its own
	sober_up(delta * sober_rate)
	
	hud.update(bac + randf_range(-0.001, 0.001))

# Fill up
func drink_booze(bac_gain: float):
	# Not realistic but whatever
	bac = min(bac + bac_gain, MAX_BAC)

# Time
func sober_up(bac_loss: float):
	bac -= bac_loss
	if bac <= 0:
		bac = 0
		get_tree().reload_current_scene()

func handle_melee() -> void:
	# Left Hook if possible
	if Input.is_action_just_pressed("attack_l"):
		if not melee_anim.is_playing():
			melee_anim.play("left_hook")
			melee_anim.queue("left_hook_return")
		elif melee_anim.current_animation == "right_hook_return":
			melee_anim.queue("left_hook")
			melee_anim.queue("left_hook_return")
	
	# Right Hook if possible
	if Input.is_action_just_pressed("attack_r"):
		if not melee_anim.is_playing():
			melee_anim.play("right_hook")
			melee_anim.queue("right_hook_return")
		elif melee_anim.current_animation == "left_hook_return":
			melee_anim.queue("right_hook")
			melee_anim.queue("right_hook_return")
	
	# Deal damage and/or pick up alcohol
	if (melee_anim.current_animation == "left_hook"
	or melee_anim.current_animation == "right_hook"):
		for body in hitbox.get_overlapping_bodies():
			if body.is_in_group("Zombie"):
				body.damage(attack_dmg)
			elif body.is_in_group("Alcohol"):
				drink_booze(body.get_amount())
				body.queue_free()

# Accepts mouse movement to change 
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sens
			pitch_input = - event.relative.y * mouse_sens
		
	
