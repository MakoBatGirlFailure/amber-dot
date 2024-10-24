extends CanvasLayer

signal loading_screen_has_full_coverage 

@onready var anim_player : AnimationPlayer = get_node("AnimationPlayer")
@onready var progress_bar : ProgressBar = get_node("Panel/ProgressBar")

func _update_progress_bar(new_value: float) -> void:
	progress_bar.set_value_no_signal(new_value * 100)

	pass

func _start_outro_animation() -> void: 
	#await Signal(anim_player, "animation_finished")
	anim_player.play("end_load")
	await Signal(anim_player, "animation_finished")
	self.queue_free()
	pass 
