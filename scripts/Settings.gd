extends Node

var RESPAWN = true
var CHILL = false
var MUSIC = true setget set_music, get_music
var SHOW_FPS = false
var SPEED:float = 0.07
var GROW_RATE:int = 10
var SCREEN_SIZE:String = "1280x720"
var SNAKE_COL_SLIDER:int = 33
var SNAKE_SIZE:int = 10

var snake_color:Color

func set_music(enabled: bool):
	MUSIC = enabled
	if enabled:
		Music.resume()
	else:
		Music.pause()
		
func get_music() -> bool:
	return MUSIC

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save()

func _ready():
	var save_file = File.new()
	if not save_file.file_exists("user://Settings.save"):
		save_file.open("user://Settings.save", File.WRITE)
		save_file.store_line(to_json(self.asJson()))
	else:
		save_file.open("user://Settings.save", File.READ)
		var jason = parse_json(save_file.get_line())
		if saveMeetsDependencies(jason):
			self.fromJson(jason)
		else:
			save_file.close()
			save_file.open("user://Settings.save", File.WRITE)
			save_file.store_line(to_json(self.asJson()))

	save_file.close()
	
	update_version()
	
	if OS.get_name()=="Android":
		get_tree().set_auto_accept_quit(false)
	
	Global.setScreenSize()

func saveMeetsDependencies(data:Dictionary):
	print("Checking save file integrity")
	var req_props = ["RESPAWN", "CHILL", "MUSIC", "SHOW_FPS", "SPEED", "GROW_RATE", "SCREEN_SIZE", "SNAKE_COL_SLIDER", "SNAKE_SIZE"]
	var nb = 0
	for i in data.keys():
		nb+=req_props.count(i)
	if nb==len(req_props):
		print("No problems found")
		return true
	else:
		print("Save file corrupted")
		return false
	
	

func asJson():
	return {
		"RESPAWN": RESPAWN,
		"CHILL": CHILL,
		"MUSIC": MUSIC,
		"SHOW_FPS": SHOW_FPS,
		"SPEED": SPEED,
		"GROW_RATE": GROW_RATE,
		"SCREEN_SIZE": SCREEN_SIZE,
		"SNAKE_COL_SLIDER": SNAKE_COL_SLIDER,
		"SNAKE_SIZE":SNAKE_SIZE
	}

func fromJson(json):
	RESPAWN = bool(json["RESPAWN"])
	CHILL = bool(json["CHILL"])
	MUSIC = bool(json["MUSIC"])
	SHOW_FPS = bool(json["SHOW_FPS"])
	SPEED = float(json["SPEED"])
	GROW_RATE = int(json["GROW_RATE"])
	SCREEN_SIZE = json["SCREEN_SIZE"]
	SNAKE_COL_SLIDER = clamp(int(json["SNAKE_COL_SLIDER"]),1,99)
	SNAKE_SIZE = int(json["SNAKE_SIZE"])
	Global.setTileSize(SNAKE_SIZE)

func save():
	var save_file = File.new()
	save_file.open("user://Settings.save", File.WRITE)
	save_file.store_line(to_json(self.asJson()))
	save_file.close()

func update_version():
	var export_config = ConfigFile.new()
	var export_config_path = "res://export_presets.cfg"
	var config_error = export_config.load(export_config_path)
	
	for section in export_config.get_sections():
		export_config.set_value(section, "application/product_version", Global.VERSION)
		export_config.set_value(section, "version/name", Global.VERSION)
	
	export_config.save(export_config_path)
