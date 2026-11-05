extends Control

@onready var main_menu_button: Button = $MainContainer/ContentContainer/VBoxContainer/MainMenuButton
@onready var leaderboard: RichTextLabel = $MainContainer/ContentContainer/LeaderboardList
@onready var top_leaderboard: RichTextLabel = $MainContainer/ContentContainer/VBoxContainer/TopLeaderboard

@onready var blue_cristal_sparkles: AnimatedSprite2D = $BlueCristalSparkles
@onready var yellow_cristal_sparkles: AnimatedSprite2D = $YellowCristalSparkles
@onready var yellow_cristal_sparkles_2: AnimatedSprite2D = $YellowCristalSparkles2
@onready var yellow_cristal_sparkles_3: AnimatedSprite2D = $YellowCristalSparkles3

var scores_path = OS.get_executable_path().get_base_dir() + "/clavier_enchante_scores.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.animations_enabled:
		blue_cristal_sparkles.play()
		yellow_cristal_sparkles.play()
		yellow_cristal_sparkles_2.play()
		yellow_cristal_sparkles_3.play()
	main_menu_button.pressed.connect(_on_main_menu)
	display_leaderboard(load_scores())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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

func display_leaderboard(scores: Array):
	var bbcode = ""
	var top_bbcode = ""
	
	for i in range(scores.size()):
		match i:
			0:
				top_bbcode += "[color=#ff4446]%s. %s - %s[/color]\n" % ["1st", scores[i]["pseudo"], scores[i]["temps"]]
			1:
				top_bbcode += "[color=#df7000]%s. %s - %s[/color]\n" % ["2nd", scores[i]["pseudo"], scores[i]["temps"]]
			2:
				top_bbcode += "[color=#929c00]%s. %s - %s[/color]\n" % ["3rd", scores[i]["pseudo"], scores[i]["temps"]]
			_:
				bbcode += "%d. %s - %s\n" % [i + 1, scores[i]["pseudo"], scores[i]["temps"]]
		
	top_leaderboard.text = ""
	top_leaderboard.append_text(top_bbcode)
	leaderboard.text = ""
	leaderboard.append_text(bbcode)
	
func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	var millis = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [minutes, secs, millis]
	
func _on_main_menu():
	Transition.fade_to_scene("res://Scenes/main_menu.tscn")
