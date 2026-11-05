extends Control

@onready var menu_container: VBoxContainer = $MenuContainer
@onready var play_button: Button = $MenuContainer/PlayButton
@onready var leaderboard_button: Button = $MenuContainer/LeaderboardButton
@onready var options_button: Button = $MenuContainer/OptionsButton
@onready var quit_button: Button = $MenuContainer/QuitButton

@onready var options_modal: Control = $OptionsModal
@onready var game_selection_modal: Control = $GameSelectionModal
@onready var rules_popup: AcceptDialog = $RulesPopup

@onready var version_text: Label = $VersionContainer/VersionVariable


var scores_path = OS.get_executable_path().get_base_dir() + "/clavier_enchante_scores.json"
var hasScore: bool = false

func _ready():
	play_button.pressed.connect(_on_play)
	leaderboard_button.pressed.connect(_on_leaderboard)
	options_button.pressed.connect(_on_options)
	quit_button.pressed.connect(_on_quit)
	display_version()
	
	if !FileAccess.file_exists(scores_path):
		leaderboard_button.disabled = true
		hasScore = false
	else:
		hasScore = true
	
	for btn in [play_button, leaderboard_button, options_button, quit_button]:
		btn.mouse_entered.connect(btn.grab_focus)

	_restore_menu_focus_modes()
	call_deferred("_focus_default_button")
	options_modal.closed.connect(_on_modal_closed)
	game_selection_modal.closed.connect(_on_modal_closed)
	game_selection_modal.game_selected.connect(_on_game_selected)
	
func display_version():
	version_text.text = GameManager.version
	
func disable_menu():
	for btn in [play_button, leaderboard_button, options_button, quit_button]:
		btn.disabled = true
		btn.focus_mode = Control.FOCUS_NONE

func enable_menu():
	_restore_menu_focus_modes()
	call_deferred("_focus_default_button")

func _restore_menu_focus_modes():
	play_button.disabled = false
	play_button.focus_mode = Control.FOCUS_ALL

	options_button.disabled = false
	options_button.focus_mode = Control.FOCUS_ALL

	quit_button.disabled = false
	quit_button.focus_mode = Control.FOCUS_ALL

	leaderboard_button.disabled = !hasScore
	leaderboard_button.focus_mode = Control.FOCUS_ALL if hasScore else Control.FOCUS_NONE

func _focus_default_button():
	if play_button.focus_mode == Control.FOCUS_ALL and !play_button.disabled:
		play_button.grab_focus()
		return

	if hasScore and !leaderboard_button.disabled and leaderboard_button.focus_mode == Control.FOCUS_ALL:
		leaderboard_button.grab_focus()
		return

	if !options_button.disabled and options_button.focus_mode == Control.FOCUS_ALL:
		options_button.grab_focus()
		return

	if !quit_button.disabled and quit_button.focus_mode == Control.FOCUS_ALL:
		quit_button.grab_focus()
	
	
func _on_modal_closed():
	enable_menu()

func _on_play():
	disable_menu()
	game_selection_modal.open()

func _on_game_selected(scene_path: String):
	Transition.fade_to_scene(scene_path)

func _on_leaderboard():
	Transition.fade_to_scene("res://Scenes/leaderboard.tscn")

func _on_rules():
	disable_menu()
	rules_popup.dialog_text = """✦ COMMENT JOUER ✦

Un sort a ete jete sur votre clavier !
Les touches ont ete melangees par un enchantement.

Phase 1 - Memorisation
Vous disposez de %d secondes pour memoriser la nouvelle disposition des touches.

Phase 2 - Incantation
Une formule magique apparait. Tapez-la le plus vite possible ! Les labels des touches sont desormais caches.

⚠ Attention
- Chaque erreur ajoute %d seconde a votre temps.
- Vous pouvez reveler le clavier, mais cela coute %d secondes.

Le mage le plus rapide remporte la victoire !""" % [int(GameManager.memorize_time), int(GameManager.wrong_key_penalty), int(GameManager.tips_penalty)]
	rules_popup.popup_centered_ratio(0.5)

func _on_options():
	disable_menu()
	options_modal.open()

func _on_rules_popup_visibility_changed():
	if !rules_popup.visible:
		enable_menu()

func _on_quit():
	get_tree().quit()
