extends Control

signal closed

@onready var title_label: Label = $Content/Title
@onready var close_button: Button = $Content/CloseButton

@onready var password_row: HBoxContainer = $Content/Body/OptionsContent/HBoxContainer
@onready var password_input: LineEdit = $Content/Body/OptionsContent/HBoxContainer/PasswordInput
@onready var protected_options: VBoxContainer = $Content/Body/OptionsContent/ProtectedOptions
@onready var sequence_input: LineEdit = $Content/Body/OptionsContent/ProtectedOptions/SequenceContainer/SequenceInput
@onready var memorize_time_input: SpinBox = $Content/Body/OptionsContent/ProtectedOptions/MemorizeTimeContainer/MemorizeTimeInput
@onready var wrong_key_penalty_input: SpinBox = $Content/Body/OptionsContent/ProtectedOptions/WrongKeyPenaltyContainer/WrongKeyPenaltyInput
@onready var tips_penalty_input: SpinBox = $Content/Body/OptionsContent/ProtectedOptions/TipsPenaltyContainer/TipsPenaltyInput
@onready var animations_check_button: CheckButton = $Content/Body/OptionsContent/AnimationsContainer/AnimationsCheckButton
@onready var screen_mode_option: OptionButton = $Content/Body/OptionsContent/VideoContainer/ScreenModeOption
@onready var save_button: Button = $Content/Body/OptionsContent/SaveOptionButton

func _ready():
	close_button.pressed.connect(_on_close)
	password_input.text_submitted.connect(_on_password_submitted)
	save_button.pressed.connect(_on_save_options)
	close_button.focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

func open():
	title_label.text = "OPTIONS"
	_reset_form_values()
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func close():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	closed.emit()

func _reset_form_values():
	sequence_input.text = GameManager.sequence
	memorize_time_input.value = GameManager.memorize_time
	wrong_key_penalty_input.value = GameManager.wrong_key_penalty
	tips_penalty_input.value = GameManager.tips_penalty
	animations_check_button.button_pressed = GameManager.animations_enabled
	screen_mode_option.selected = GameManager.screen_mode

	protected_options.visible = false
	password_row.visible = true
	password_input.text = ""
	password_input.placeholder_text = ""

	save_button.disabled = false
	save_button.text = "Sauvegarder"

func _on_password_submitted(text: String):
	if text == GameManager.game_rules_password:
		protected_options.visible = true
		password_row.visible = false
		return

	password_input.text = ""
	password_input.placeholder_text = "Mot de passe incorrect"

func _on_save_options():
	get_viewport().gui_release_focus()

	GameManager.animations_enabled = animations_check_button.button_pressed
	GameManager.sequence = sequence_input.text.to_upper()

	memorize_time_input.apply()
	GameManager.memorize_time = memorize_time_input.value

	wrong_key_penalty_input.apply()
	GameManager.wrong_key_penalty = wrong_key_penalty_input.value

	tips_penalty_input.apply()
	GameManager.tips_penalty = tips_penalty_input.value

	match screen_mode_option.selected:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			GameManager.screen_mode = 0
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			GameManager.screen_mode = 1

	GameManager.save_config()

	save_button.text = "Sauvegarde !"
	await get_tree().create_timer(1.5).timeout
	save_button.disabled = true

func _on_close():
	close()
