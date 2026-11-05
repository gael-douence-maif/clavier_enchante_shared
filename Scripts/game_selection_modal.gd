extends Control

signal closed
signal game_selected(scene_path: String)

@onready var close_button: Button = $Content/SelectionAndRules/GameListContainer/CloseButton
@onready var classic_button: Button = $Content/SelectionAndRules/GameListContainer/GameButton/ClassicButton
@onready var new_game_button: Button = $Content/SelectionAndRules/GameListContainer/GameButton/NewGameButton
@onready var rules_panel: PanelContainer = $RulesPanel
@onready var rules_text: RichTextLabel = $RulesPanel/Margin/RulesContainer/RulesText
@onready var cadre_regles: TextureRect = $CadreRegles

var is_close_button_hovered: bool = false
var is_keyboard_navigation_mode: bool = false

func _ready():
	close_button.pressed.connect(_on_close)
	close_button.mouse_entered.connect(_on_close_button_mouse_entered)
	close_button.mouse_exited.connect(_on_close_button_mouse_exited)
	close_button.focus_entered.connect(_on_close_button_focus_entered)
	close_button.focus_exited.connect(_on_close_button_focus_exited)
	classic_button.pressed.connect(_on_classic_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	classic_button.focus_entered.connect(func(): _show_rules_for_game("classic"))
	classic_button.focus_exited.connect(_on_game_button_focus_exited)
	new_game_button.focus_entered.connect(func(): _show_rules_for_game("new_game"))
	new_game_button.focus_exited.connect(_on_game_button_focus_exited)
	close_button.focus_mode = Control.FOCUS_ALL
	if new_game_button.disabled:
		new_game_button.focus_mode = Control.FOCUS_NONE
	else:
		new_game_button.focus_mode = Control.FOCUS_ALL

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_keyboard_navigation_mode(false)
	rules_panel.visible = false
	visible = false

func open():
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	modulate.a = 0.0
	is_close_button_hovered = false
	rules_panel.visible = false
	rules_text.text = ""
	_set_keyboard_navigation_mode(true)
	classic_button.grab_focus()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func close():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_keyboard_navigation_mode(false)
	closed.emit()

func _unhandled_input(event):
	if !visible:
		return

	if event is InputEventMouseMotion:
		_set_keyboard_navigation_mode(false)
		return

	if event is InputEventMouseButton and event.pressed:
		_set_keyboard_navigation_mode(false)
		return

	if event is InputEventKey and event.pressed and !event.echo:
		if event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_prev") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
			_set_keyboard_navigation_mode(true)

func _set_keyboard_navigation_mode(enabled: bool):
	if is_keyboard_navigation_mode == enabled:
		return

	is_keyboard_navigation_mode = enabled

	for button in [classic_button, new_game_button, close_button]:
		if !is_instance_valid(button):
			continue
		if enabled:
			button.add_theme_stylebox_override("hover", button.get_theme_stylebox("normal"))
		else:
			button.remove_theme_stylebox_override("hover")

func _on_classic_pressed():
	game_selected.emit("res://Scenes/classic_mode.tscn")
	close()

func _on_new_game_pressed():
	game_selected.emit("res://Scenes/instable_mode.tscn")
	close()

func _on_close():
	close()

func _show_rules_for_game(game_id: String):
	if is_close_button_hovered:
		rules_panel.visible = false
		cadre_regles.visible = false
		return
	rules_panel.visible = true
	cadre_regles.visible = true
	match game_id:
		"classic":
			rules_text.text = _build_classic_rules()
		"new_game":
			rules_text.text = _build_new_game_rules()
		_:
			rules_text.text = ""

func _on_game_button_focus_exited():
	call_deferred("_hide_rules_panel_if_no_game_focused")

func _hide_rules_panel_if_no_game_focused():
	if is_close_button_hovered:
		rules_panel.visible = false
		cadre_regles.visible = false
		return
	if classic_button.has_focus() or new_game_button.has_focus():
		return
	cadre_regles.visible = false
	rules_panel.visible = false

func _on_close_button_mouse_entered():
	is_close_button_hovered = true
	rules_panel.visible = false
	cadre_regles.visible = false

func _on_close_button_mouse_exited():
	is_close_button_hovered = false
	if classic_button.has_focus():
		_show_rules_for_game("classic")
	elif new_game_button.has_focus():
		_show_rules_for_game("new_game")

func _on_close_button_focus_entered():
	rules_panel.visible = false
	cadre_regles.visible = false

func _on_close_button_focus_exited():
	if classic_button.has_focus():
		_show_rules_for_game("classic")
	elif new_game_button.has_focus():
		_show_rules_for_game("new_game")

func _build_classic_rules() -> String:
	return """[color=#ffcc00]✦ CLASSIC[/color]

[color=#d4c4a0]Un sort a ete jete sur votre clavier !
Les touches ont ete melangees par un enchantement.

[color=#7adfff]Phase 1 - Memorisation[/color]
Vous disposez de %d secondes pour memoriser la nouvelle disposition des touches.

[color=#7adfff]Phase 2 - Incantation[/color]
Une formule magique apparait. Tapez-la le plus vite possible !

[color=#ff7a7a]⚠ Attention[/color]
- Chaque erreur ajoute %d seconde a votre temps.
- Reveler le clavier coute %d secondes.

[color=#7aff7a]Le mage le plus rapide remporte la victoire ![/color][/color]""" % [int(GameManager.memorize_time), int(GameManager.wrong_key_penalty), int(GameManager.tips_penalty)]

func _build_new_game_rules() -> String:
	return """[color=#ffcc00]✦ MODE INSTABLE[/color]

[color=#d4c4a0]Tapez la meme formule magique que dans Classic,
mais le clavier se remappe toutes les secondes.[/color]

[color=#7adfff]Regles[/color]
- Le clavier reste visible en permanence.
- Aucune penalite de temps sur erreur.
- A la moindre erreur, la sequence repart du debut.

[color=#7aff7a]Gardez votre calme et adaptez-vous au chaos ![/color]"""
