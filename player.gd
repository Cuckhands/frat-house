extends RigidBody3D

@onready var neck_pivot: Node3D = $NeckPivot
@onready var camera: Camera3D = $NeckPivot/Camera3D

@export var mouse_sens: float = 0.001
# Gives roughly 20 seconds
@export var sober_rate: float = 0.002
var bac: float = 0.04
const MAX_BAC: float = 0.21
const MOVE_FORCE: float = 1000.0
var twist_input: float = 0.0 # For horizontal camera motion
var pitch_input: float = 0.0 # For vertical camera motion

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
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# DEBUG PURPOSES
	if Input.is_action_just_pressed("ui_page_up"):
		drink_booze(0.02)
	if Input.is_action_just_pressed("ui_page_down"):
		sober_up(0.04)
	#print(bac)
	
	neck_pivot.rotate_y(twist_input)
	camera.rotate_x(pitch_input)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	twist_input = 0.0
	pitch_input = 0.0
	
	# BAC goes down on its own
	sober_up(delta * sober_rate)

# Fill up
func drink_booze(bac_gain: float):
	# Not realistic but whatever
	bac = min(bac + bac_gain, MAX_BAC)

# Time
func sober_up(bac_loss: float):
	bac -= bac_loss
	if bac <= 0:
		bac = 0
		print("dead")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sens
			pitch_input = - event.relative.y * mouse_sens
		
	
