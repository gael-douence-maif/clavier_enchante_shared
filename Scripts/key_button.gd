extends Control

signal key_clicked(letter: String)

@onready var button: Button = $Button

var scan_code: int = 0
var key_letter: String = ""
var is_space_key: bool = false

var reveal_timer: Timer = null
var active_tween: Tween = null

var is_global_reveal: bool = false

const SPACE_NORMAL = preload("res://Assets/keyboard/Clavier enchanté - 456x78 - normal space key.png")
const SPACE_PRESSED = preload("res://Assets/keyboard/Clavier enchanté - 456x78 - pressed space key.png")

var original_style: StyleBox = null

var hidden_label: String = "?"
var real_label: String = ""
var shuffled_letter: String = ""

func _ready():
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	await get_tree().process_frame
	original_style = button.get_theme_stylebox("normal").duplicate()
	button.pressed.connect(_on_button_pressed)
	button.focus_mode = Control.FOCUS_NONE
	
func _on_button_pressed():
	key_clicked.emit(key_letter)

func setup(letter: String, sc: int):
	key_letter = letter
	scan_code = sc
	button.text = letter
	button.focus_mode = Control.FOCUS_NONE

func setup_space(letter: String, sc: int):
	key_letter = letter
	scan_code = sc
	button.text = letter
	button.focus_mode = Control.FOCUS_NONE
	is_space_key = true
	
	var style_normal = StyleBoxTexture.new()
	style_normal.texture = SPACE_NORMAL
	style_normal.content_margin_bottom = 30
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_normal)
	
	var style_pressed = StyleBoxTexture.new()
	style_pressed.texture = SPACE_PRESSED
	style_pressed.content_margin_bottom = 16
	button.add_theme_stylebox_override("pressed", style_pressed)
	
	button.custom_minimum_size = Vector2(456, 78)
	
	# Sauvegarder le style normal après l'avoir appliqué
	
	original_style = style_normal.duplicate()

func set_pressed_visual(is_pressed: bool):
	if is_pressed:
		var pressed_style = button.get_theme_stylebox("pressed")
		if not is_space_key:
			pressed_style.content_margin_right = 8
			pressed_style.content_margin_bottom = 16
		button.add_theme_stylebox_override("normal", pressed_style)
	else:
		if original_style:
			button.add_theme_stylebox_override("normal", original_style)

func reveal_temporarily(duration: float = 2.0):
	# Annuler tout reveal précédent
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	if reveal_timer and is_instance_valid(reveal_timer):
		reveal_timer.stop()
		reveal_timer.queue_free()
	
	if shuffled_letter == "":
		return
	
	# Fade in
	button.text = shuffled_letter
	button.add_theme_color_override("font_color", Color(0, 0, 0, 0))
	active_tween = create_tween()
	active_tween.tween_method(
		func(alpha): button.add_theme_color_override("font_color", Color(0, 0, 0, alpha)),
		0.0, 1.0, 0.5
	)
	
	# Timer pour masquer
	reveal_timer = Timer.new()
	reveal_timer.one_shot = true
	reveal_timer.wait_time = duration
	reveal_timer.timeout.connect(_hide_label)
	add_child(reveal_timer)
	reveal_timer.start()

func _hide_label():
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	if button.text == shuffled_letter:
		active_tween = create_tween()
		active_tween.tween_method(
			func(alpha): button.add_theme_color_override("font_color", Color(0, 0, 0, alpha)),
			1.0, 0.0, 0.5
		)
		await active_tween.finished
		button.text = "?"
		button.add_theme_color_override("font_color", Color(0, 0, 0, 1))

func set_label(new_label: String):
	key_letter = new_label
	if new_label != "?":
		shuffled_letter = new_label  # sauvegarder le label avant masquage
	if new_label == "␣" and not is_space_key:
		button.text = "_"
	else:
		button.text = new_label
