extends Sprite2D

func _ready():
	start_pulse()

func start_pulse():
	var tween = create_tween()
	tween.set_loops()  # boucle infinie
	# Devient plus lumineux
	tween.tween_property(self, "modulate", Color(1.5, 1.5, 2.0, 1.0), 1.0)
	# Revient à la normale
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)
