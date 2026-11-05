extends Node

# General settings
var version: String = "1.0.6"
var game_rules_password = "Ranger"
var config_path = OS.get_executable_path().get_base_dir() + "/clavier_enchante_config.json"

# Graphic settings
var animations_enabled: bool = true
var screen_mode: int = 0 # 0: fenetre , 1: plein ecran

# Classic Game
var current_timer: float = 0.0
var timer_speed: float = 1.0
var is_game_running: bool = false
var wrong_key_penalty: float = 2.0
var tips_penalty: float = 20.0
var sequence: String = "LES STATUETTES DE GLADEULFEURHA"
var memorize_time: float = 30.0

func _ready():
	load_config()

func start_new_run():
	current_timer = 0.0
	timer_speed = 1.0
	is_game_running = false

func on_wrong_key():
	current_timer += wrong_key_penalty
	
func on_tips():
	current_timer += tips_penalty

func update_timer(delta: float):
	if is_game_running:
		current_timer += delta * timer_speed
		
func save_config():
	var config = {
		"sequence": sequence,
		"memorize_time": memorize_time,
		"animations_enabled": animations_enabled,
		"wrong_key_penalty": wrong_key_penalty,
		"tips_penalty": tips_penalty,
		"screen_mode": screen_mode
	}
	var file = FileAccess.open(config_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(config, "\t"))
	file.close()

func load_config():
	if FileAccess.file_exists(config_path):
		var file = FileAccess.open(config_path, FileAccess.READ)
		var json = JSON.new()
		var result = json.parse(file.get_as_text())
		file.close()
		if result == OK:
			var config = json.data
			sequence = config.get("sequence", sequence)
			memorize_time = config.get("memorize_time", memorize_time)
			animations_enabled = config.get("animations_enabled", animations_enabled)
			wrong_key_penalty = config.get("wrong_key_penalty", wrong_key_penalty)
			tips_penalty = config.get("tips_penalty", tips_penalty)
			screen_mode = config.get("screen_mode", screen_mode)
