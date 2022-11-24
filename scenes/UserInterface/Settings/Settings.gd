extends Panel

onready var GPAInput = $HBoxContainer/Server/GPA/LineEdit
onready var RespawnInput = $HBoxContainer/Server/Respawn
onready var ChillModeInput = $HBoxContainer/Server/ChillMode
onready var SnakeSizeInput = $HBoxContainer/Server/SnakeSize/LineEdit

onready var ShowFpsInput = $HBoxContainer/Client/ShowFps
onready var MusicInput = $HBoxContainer/Client/Music
onready var ScreenSizeOption = $HBoxContainer/Client/ScreenSize/OptionButton

func _ready():
	GPAInput.text = str(Settings.GROW_RATE)
	RespawnInput.pressed = Settings.RESPAWN
	ChillModeInput.pressed = Settings.CHILL
	SnakeSizeInput.text = str(Settings.SNAKE_SIZE)

	ShowFpsInput.pressed = Settings.SHOW_FPS
	MusicInput.pressed = Settings.MUSIC

	addScreenOptions()

func _on_Back_pressed():
	Settings.save()
	get_tree().change_scene("res://scenes/UserInterface/TitleScreen/TitleScreen.tscn")


func _on_Respawn_toggled(button_pressed):
	Settings.RESPAWN = button_pressed


func _on_ChillMode_toggled(button_pressed):
	Settings.CHILL = button_pressed


func _on_ShowFps_toggled(button_pressed):
	FPS.visible = button_pressed
	Settings.SHOW_FPS = button_pressed

func addScreenOptions():
	var optionsStr:Array = ["640x360", "854x480", "1280x720", "1920x1080", "Fullscreen"]
	
	for i in range(len(optionsStr)):
		ScreenSizeOption.add_item(optionsStr[i])
		if optionsStr[i]==Settings.SCREEN_SIZE:
			ScreenSizeOption.selected = i

	


func _on_OptionButton_item_selected(index):
	var size_text:String = ScreenSizeOption.get_item_text(index)
	Settings.SCREEN_SIZE = size_text
	Global.setScreenSize()
		


func _on_Music_toggled(button_pressed):
	Settings.MUSIC = button_pressed




func _on_LineEdit_focus_exited():
	var regex = RegEx.new()
	regex.compile("([0-9])+")
	var new_text = GPAInput.text
	var out = regex.search(new_text)
	if out:
		if len(out.strings[0])==len(new_text) and int(new_text)>=1:
			Settings.GROW_RATE = int(new_text)
			return

	if new_text:
		GPAInput.text = str(Settings.GROW_RATE)


func _on_SnakeSize_LineEdit_focus_exited():
	var regex = RegEx.new()
	regex.compile("([0-9])+")
	var new_text = SnakeSizeInput.text
	var out = regex.search(new_text)
	if out:
		if len(out.strings[0])==len(new_text) and int(new_text)>1 and int(new_text)<=60:
			Settings.SNAKE_SIZE = int(new_text)
			Global.setTileSize(Settings.SNAKE_SIZE)
			return

	if new_text:
		SnakeSizeInput.text = str(Settings.SNAKE_SIZE)
