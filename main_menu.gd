extends Control

const GAME = preload("res://test_world.tscn")

@onready var anim: AnimationPlayer = $fade_out
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Play.pressed.connect(_on_play_pressed)
	$Exit.pressed.connect(_on_exit_pressed)

func _on_play_pressed() -> void:
	anim.play("fade_out")
	await anim.animation_finished
	get_tree().change_scene_to_packed(GAME)
	print("Play pressed!")
func _on_exit_pressed() -> void:
	get_tree().quit()
	print("Exit pressed!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
