extends RigidBody3D

@onready var neck_pivot: Node3D = $NeckPivot

const MOVE_FORCE: float = 1000.0
var twist_input: float = 0.0 # For horizontal camera motion
var pitch_input: float = 0.0 # For vertical camera motion

# Runs at initialization
func _ready() -> void:
	pass

# Runs every frame; delta represents the elapsed time since the last frame
func _process(delta: float) -> void:
	var frame = Engine.get_frames_drawn()

	# Randomize direction for testing
	if frame % 60 == 0:
		twist_input += randfn(0.0, 1.0)
		pitch_input += randfn(0.0, 0.3)
	neck_pivot.rotate_y(twist_input)
	
	# Move constantly
	apply_central_force(neck_pivot.basis * Vector3.FORWARD * delta * MOVE_FORCE)
	
	#neck_pivot.rotate_x(pitch_input)
	#neck_pivot.rotation.x = clamp(neck_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	twist_input = 0.0
	pitch_input = 0.0
