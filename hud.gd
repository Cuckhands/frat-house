extends Control

@onready var progress_bar: ProgressBar = $ProgressBar

func update(bac: float) -> void:
	progress_bar.set_value_no_signal(bac)
