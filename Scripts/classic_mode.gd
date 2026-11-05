extends Control

@onready var sequence_label: RichTextLabel = $SequenceLabel
@onready var keyboard: VBoxContainer = $Keyboard
@onready var timer: Label = $TimerPanel/TimerVerticalContainer/Timer
@onready var form_container: VBoxContainer = $FormContainer
@onready var pseudo_input: LineEdit = $FormContainer/PseudoContainer/PseudoInput
@onready var email_input: LineEdit = $FormContainer/EmailContainer/EmailInput
@onready var save_button: Button = $FormContainer/SaveButton

@onready var timer_gear: AnimatedSprite2D = $TimerPanel/TimerGear
@onready var parchment_sparkles: AnimatedSprite2D = $ParchmentSparkles

@onready var restart_button: Button = $SideButtons/RestartButton
@onready var reveal_button: Button = $SideButtons/RevealButton
@onready var main_menu_button: Button = $SideButtons/MainMenuButton

@onready var victory_container: HBoxContainer = $VictoryContainer
@onready var leaderboard: RichTextLabel = $VictoryContainer/LeaderboardContainer/Leaderboard

var scores_path = OS.get_executable_path().get_base_dir() + "/clavier_enchante_scores.json"

var current_sequence: Array[String] = []
var current_index: int = 0
var key_map: Dictionary = {}
var shuffled_labels: Dictionary = {} # real_label -> fake_label
var reverse_shuffle: Dictionary = {} # fake_label -> real_label
enum GamePhase {MEMORIZE, PLAY, END}
var current_phase: GamePhase = GamePhase.MEMORIZE
var memorize_timer: float = GameManager.memorize_time

var keyboard_layout: Array = []
var physical_key_map: Dictionary = {}

const KeyButton = preload("res://Scenes/key_button.tscn")

func get_keyboard_layout() -> Array:
	var test_key = DisplayServer.keyboard_get_label_from_physical(KEY_Q)
	var is_azerty = (char(test_key).to_upper() == "A")
	
	if is_azerty:
		return [
			[16, 17, 18, 19, 20, 21, 22, 23, 24, 25],
			[30, 31, 32, 33, 34, 35, 36, 37, 38, 39],
			[44, 45, 46, 47, 48, 49],
			[57],
		]
	else: # QWERTY et QWERTZ
		return [
			[16, 17, 18, 19, 20, 21, 22, 23, 24, 25],
			[30, 31, 32, 33, 34, 35, 36, 37, 38],
			[44, 45, 46, 47, 48, 49, 50],
			[57],
		]

func _ready():
	victory_container.visible = false
	parchment_sparkles.play()
	GameManager.start_new_run()
	
	reveal_button.pressed.connect(_on_reveal_pressed)
	reveal_button.focus_mode = Control.FOCUS_NONE
	save_button.pressed.connect(_on_save_pressed)
	save_button.focus_mode = Control.FOCUS_NONE
	main_menu_button.pressed.connect(_on_main_menu)
	main_menu_button.focus_mode = Control.FOCUS_NONE
	restart_button.pressed.connect(restart_game)
	restart_button.focus_mode = Control.FOCUS_NONE
	
	keyboard_layout = get_keyboard_layout()
	generate_keyboard()
	call_deferred("shuffle_keyboard")
	call_deferred("start_memorize_phase")
	form_container.visible = false


func _process(delta):
	if !GameManager.animations_enabled:
		timer_gear.stop()
		parchment_sparkles.stop()
		parchment_sparkles.frame = 2
	if current_phase == GamePhase.MEMORIZE:
		memorize_timer -= delta
		timer.text = format_time(memorize_timer)
		timer.add_theme_color_override("font_color", "#d4c4a0")
		if memorize_timer <= 0:
			start_play_phase()
		elif memorize_timer <= 12 && (int(memorize_timer) % 2 == 0):
			timer.add_theme_color_override("font_color", "#ff5657")

	elif current_phase == GamePhase.PLAY:
		GameManager.update_timer(delta)
		timer.text = format_time(GameManager.current_timer)
			
func restart_game():
	Transition.fade_to_scene("res://Scenes/classic_mode.tscn")
	
func start_memorize_phase():
	reveal_button.disabled = true
	current_phase = GamePhase.MEMORIZE
	memorize_timer = GameManager.memorize_time
	sequence_label.text = ""
	sequence_label.append_text("Memorisez bien le clavier !")
	
	
func start_play_phase():
	reveal_button.disabled = false
	#sequence_label.add_theme_font_size_override("normal_font_size", 110)
	timer_gear.play()
	current_phase = GamePhase.PLAY
	
	var tween_out = create_tween()
	tween_out.tween_property(sequence_label, "modulate:a", 0.0, 0.5)
	await tween_out.finished
	
	GameManager.is_game_running = true
	GameManager.current_timer = 0.0
	current_index = 0
	# Cacher les labels des touches
	for key in key_map:
		if (key.length() == 1 and key >= "A" and key <= "Z") or key == "_":
			key_map[key].set_label("?")
	display_sequence()
	
	var tween_in = create_tween()
	sequence_label.add_theme_font_size_override("normal_font_size", 90)
	tween_in.tween_property(sequence_label, "modulate:a", 1.0, 0.5)
	
func start_end_phase():
	reveal_button.disabled = true
	reveal_button.visible = false
	timer_gear.stop()
	current_phase = GamePhase.END
	GameManager.is_game_running = false
	
	var tween = create_tween()
	tween.tween_property(keyboard, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	keyboard.visible = false
	reveal_button.visible = false
	form_container.visible = true
	sequence_label.visible = false
	
	var tween2 = create_tween()
	tween2.tween_property(form_container, "modulate:a", 1.0, 0.5)
	
	display_leaderboard(load_scores())
	pseudo_input.grab_focus()

func generate_keyboard():
	var row_offsets = [0, 20, 45, 150]
	
	for row_index in range(keyboard_layout.size()):
		var row = keyboard_layout[row_index]
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", row_offsets[row_index])
		keyboard.add_child(margin)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 20)
		margin.add_child(hbox)
		
		for scan_code in row:
			var label = get_key_label(scan_code)
			var key_instance = KeyButton.instantiate()
			hbox.add_child(key_instance)
			if scan_code == 57:
				key_instance.call_deferred("setup_space", label, scan_code)
			else:
				key_instance.call_deferred("setup", label, scan_code)
			key_map[label] = key_instance
			physical_key_map[label] = key_instance # même clé au départ

func get_key_label(scan_code: int) -> String:
	var special_keys = {
		57: "_",
	}
	if special_keys.has(scan_code):
		return special_keys[scan_code]
	
	var physical_to_godot = {
		16: KEY_Q, 17: KEY_W, 18: KEY_E, 19: KEY_R, 20: KEY_T,
		21: KEY_Y, 22: KEY_U, 23: KEY_I, 24: KEY_O, 25: KEY_P,
		30: KEY_A, 31: KEY_S, 32: KEY_D, 33: KEY_F, 34: KEY_G,
		35: KEY_H, 36: KEY_J, 37: KEY_K, 38: KEY_L, 39: KEY_SEMICOLON,
		44: KEY_Z, 45: KEY_X, 46: KEY_C, 47: KEY_V, 48: KEY_B,
		49: KEY_N, 50: KEY_M
	}
	
	if physical_to_godot.has(scan_code):
		var godot_key = physical_to_godot[scan_code]
		var label_key = DisplayServer.keyboard_get_label_from_physical(godot_key)
		if label_key != KEY_NONE:
			return char(label_key).to_upper()
	return "?"

func generate_sequence(length: int):
	current_sequence.clear()
	for i in range(length):
		var random_index = randi() % GameManager.character_pool.size()
		current_sequence.append(GameManager.character_pool[random_index])
	current_index = 0

func display_sequence():
	var bbcode = ""
	for i in range(GameManager.sequence.length()):
		var c = GameManager.sequence[i]
		if i < current_index:
			bbcode += "[color=#99875f]" + c + "[/color]"
		elif i == current_index:
			bbcode += "[u][color=#2aafa5]" + c + "[/color][/u]"
		else:
			bbcode += "[color=#d4c4a0]" + c + "[/color]"
	sequence_label.text = ""
	sequence_label.append_text(bbcode)

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		var typed = event.as_text_key_label().to_upper()
				
		if typed == "BACKSPACE":
			_on_reveal_pressed()
			return
		
		if typed == "CTRL+R":
			restart_game()
			return
			
		if typed == "ESCAPE":
			_on_main_menu()
			return
			
		if current_phase != GamePhase.PLAY:
			return
		
		# Convertir la touche espace en "Space" pour le shuffle
		if typed == "SPACE":
			typed = "_"
		
		# Synchro visuelle
		if physical_key_map.has(typed):
			physical_key_map[typed].set_pressed_visual(true)
			
			
		if current_phase == GamePhase.PLAY:
			physical_key_map[typed].reveal_temporarily(2.0)
			
			var actual_typed = typed
			if shuffled_labels.has(typed):
				actual_typed = shuffled_labels[typed]
			
			# Convertir "Space" en " " pour la comparaison avec la séquence
			if actual_typed == "_":
				actual_typed = " "
			
			var expected = GameManager.sequence[current_index]
			
			if actual_typed == expected:
				current_index += 1
				
				display_sequence()
				if current_index >= GameManager.sequence.length():
					start_end_phase()
			elif typed.length() == 1 or typed == "Space":
				GameManager.on_wrong_key()
	
	elif event is InputEventKey and not event.pressed:
		var typed = event.as_text_key_label().to_upper()
		if typed == "SPACE":
			typed = "_"
		if physical_key_map.has(typed):
			physical_key_map[typed].set_pressed_visual(false)

func shuffle_keyboard():
	var letters: Array[String] = []
	for key in key_map:
		if (key.length() == 1 and key >= "A" and key <= "Z") or key == "_":
			letters.append(key)
	
	var shuffled = letters.duplicate()
	shuffled.shuffle()
	
	for i in range(letters.size()):
		shuffled_labels[letters[i]] = shuffled[i]
		reverse_shuffle[shuffled[i]] = letters[i]
	
	for real_label in shuffled_labels:
		if key_map.has(real_label):
			key_map[real_label].set_label(shuffled_labels[real_label])
			
func _on_reveal_pressed():
	if current_phase != GamePhase.PLAY:
		return
	GameManager.on_tips()
	for real_label in shuffled_labels:
		if key_map.has(real_label):
			key_map[real_label].reveal_temporarily(3.0)

func load_scores() -> Array:
	var scores = []
	if FileAccess.file_exists(scores_path):
		var file = FileAccess.open(scores_path, FileAccess.READ)
		var json = JSON.new()
		var result = json.parse(file.get_as_text())
		file.close()
		if result == OK:
			scores = json.data
	return scores

func _on_save_pressed():
	var pseudo = pseudo_input.text.strip_edges()
	var email = email_input.text.strip_edges()
	
	if pseudo.is_empty() or email.is_empty():
		return
	
	var scores = load_scores()
	scores.append({"pseudo": pseudo, "email": email, "temps": format_time(GameManager.current_timer)})
	scores.sort_custom(func(a, b): return a["temps"] < b["temps"])
	
	var file = FileAccess.open(scores_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(scores, "\t"))
	file.close()
	
	save_button.text = "Sauvegardé !"
	save_button.disabled = true
	
	_on_main_menu()
	
func display_leaderboard(scores: Array):
	victory_container.visible = true

	var is_in_top = false
	var bbcode = ""
	
	scores.append({"pseudo": "VOUS", "email": "", "temps": format_time(GameManager.current_timer)})
	scores.sort_custom(func(a, b): return a["temps"] < b["temps"])

	for i in range(scores.size()):
		if i < 3:
			if scores[i]["pseudo"] == "VOUS" && is_in_top == false:
				bbcode += "[color=#2aafa5]%d. %s - %s[/color]\n" % [i + 1, scores[i]["pseudo"], scores[i]["temps"]]
				is_in_top = true
			else:
				bbcode += "[color=#cccccc]%d. %s - %s[/color]\n" % [i + 1, scores[i]["pseudo"], scores[i]["temps"]]
		elif is_in_top:
			break
		elif scores[i]["pseudo"] == "VOUS" && is_in_top == false:
				if i > 3:
					bbcode += "...\n"
				bbcode += "[color=#2aafa5]%d. %s - %s[/color]\n" % [i + 1, "VOUS", scores[i]["temps"]]
				break

	leaderboard.text = ""
	leaderboard.append_text(bbcode)
	
func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	var millis = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [minutes, secs, millis]
	
func _on_main_menu():
	Transition.fade_to_scene("res://Scenes/main_menu.tscn")
