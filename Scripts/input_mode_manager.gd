extends Node

signal input_mode_changed(new_mode: int)

enum InputMode {
	MOUSE,
	KEYBOARD,
	GAMEPAD,
}

var current_input_mode: InputMode = InputMode.MOUSE

func _ready():
	get_tree().node_added.connect(_on_node_added)
	_apply_mode_to_all_buttons()
	_set_mouse_visibility_from_mode()

func _input(event):
	if event is InputEventMouseMotion:
		_set_input_mode(InputMode.MOUSE)
		return

	if event is InputEventMouseButton and event.pressed:
		_set_input_mode(InputMode.MOUSE)
		return

	if event is InputEventJoypadButton and event.pressed:
		_set_input_mode(InputMode.GAMEPAD)
		return

	if event is InputEventJoypadMotion and abs(event.axis_value) > 0.2:
		_set_input_mode(InputMode.GAMEPAD)
		return

	if event is InputEventKey and event.pressed and !event.echo:
		_set_input_mode(InputMode.KEYBOARD)

func _set_input_mode(new_mode: InputMode):
	if current_input_mode == new_mode:
		return

	current_input_mode = new_mode
	_set_mouse_visibility_from_mode()
	_apply_mode_to_all_buttons()
	input_mode_changed.emit(new_mode)

func _set_mouse_visibility_from_mode():
	if current_input_mode == InputMode.MOUSE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _apply_mode_to_all_buttons():
	var root = get_tree().root
	if root == null:
		return
	_apply_mode_to_tree(root)

func _apply_mode_to_tree(node: Node):
	if node is BaseButton:
		_apply_mode_to_button(node)

	for child in node.get_children():
		_apply_mode_to_tree(child)

func _apply_mode_to_button(button: BaseButton):
	if current_input_mode == InputMode.MOUSE:
		button.remove_theme_stylebox_override("hover")
		button.remove_theme_stylebox_override("hover_pressed")
		return

	var normal_style = button.get_theme_stylebox("normal")
	if normal_style:
		button.add_theme_stylebox_override("hover", normal_style)

	var pressed_style = button.get_theme_stylebox("pressed")
	if pressed_style:
		button.add_theme_stylebox_override("hover_pressed", pressed_style)

func _on_node_added(node: Node):
	if current_input_mode == InputMode.MOUSE:
		return

	if node is BaseButton:
		call_deferred("_apply_mode_to_button", node)
