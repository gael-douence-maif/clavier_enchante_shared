extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func _ready():
	color_rect.color = Color(0, 0, 0, 0)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_to_scene(scene_path: String):
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file(scene_path)
	var tween2 = create_tween()
	tween2.tween_property(color_rect, "color:a", 0.0, 0.5)
	await tween2.finished
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_out(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, duration)
	await tween.finished

func fade_in(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, duration)
	await tween.finished
