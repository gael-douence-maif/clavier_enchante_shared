extends AnimatedSprite2D

func _ready():
	var animations_enabled = GameManager.animations_enabled
	
	stop()
	if animations_enabled:
		set_frame(0)
		animation_finished.connect(_on_animation_finished)
		var delay = randf_range(0.0, 10.0)
		await get_tree().create_timer(delay).timeout
		play()

func _process(_delta: float) -> void:
	var animations_enabled = GameManager.animations_enabled
	
	if !animations_enabled:
		frame = 4
		stop()	

func _on_animation_finished():
	stop()
	frame = 0
	# Pause aléatoire entre les scintillements
	var wait_time = randf_range(2.0, 8.0)
	await get_tree().create_timer(wait_time).timeout
	play()
