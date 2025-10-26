extends Node

@onready var main_menu: Control = $"Main Menu"
@onready var world: Node3D = $World
@onready var main_menu_scn = preload("res://main_menu.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and !main_menu:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		var pause_menu = main_menu_scn.instantiate()
		add_child(pause_menu)
