extends Panel


func _ready():
	$Server/GPA/LineEdit.text = str(Settings.GROW_RATE)
	$Server/Respawn.pressed = Settings.RESPAWN
	$Server/ChillMode.pressed = Settings.CHILL
	$Server/GPA/LineEdit.text = str(Settings.GROW_RATE)
	$Server/SnakeSize/LineEdit.text = str(Settings.SNAKE_SIZE)

	$Client/ShowFps.pressed = Settings.SHOW_FPS
	$Client/Music.pressed = Settings.MUSIC
	$Client/ShowFps.pressed = Settings.SHOW_FPS
	$Client/ShowFps.pressed = Settings.SHOW_FPS
	$Client/ShowFps.pressed = Settings.SHOW_FPS

	addScreenOptions()

func _on_Back_pressed():
	Settings.save()
	get_tree().change_scene("res://scenes/TitleScreen/TitleScreen.tscn")


func _on_Respawn_toggled(button_pressed):
	Settings.RESPAWN = button_pressed


func _on_ChillMode_toggled(button_pressed):
	Settings.CHILL = button_pressed


func _on_ShowFps_toggled(button_pressed):
	FPS.visible = button_pressed
	Settings.SHOW_FPS = button_pressed

func addScreenOptions():
	var options = $Client/ScreenSize/OptionButton
	var optionsStr:Array = ["640x360", "854x480", "1280x720", "1920x1080", "Fullscreen"]
	
	for i in range(len(optionsStr)):
		options.add_item(optionsStr[i])
		if optionsStr[i]==Settings.SCREEN_SIZE:
			options.selected = i

	


func _on_OptionButton_item_selected(index):
	var size_text:String = $Client/ScreenSize/OptionButton.get_item_text(index)
	Settings.SCREEN_SIZE = size_text
	Global.setScreenSize()
		


func _on_Music_toggled(button_pressed):
	Settings.MUSIC = button_pressed




func _on_LineEdit_focus_exited():
	var regex = RegEx.new()
	regex.compile("([0-9])+")
	var new_text = $Server/GPA/LineEdit.text
	var out = regex.search(new_text)
	if out:
		if len(out.strings[0])==len(new_text) and int(new_text)>=1:
			Settings.GROW_RATE = int(new_text)
			return

	if new_text:
		$Server/GPA/LineEdit.text = str(Settings.GROW_RATE)


func _on_SnakeSize_LineEdit_focus_exited():
	var regex = RegEx.new()
	regex.compile("([0-9])+")
	var new_text = $Server/SnakeSize/LineEdit.text
	var out = regex.search(new_text)
	if out:
		if len(out.strings[0])==len(new_text) and int(new_text)>1 and int(new_text)<=60:
			Settings.SNAKE_SIZE = int(new_text)
			Global.setTileSize(Settings.SNAKE_SIZE)
			return

	if new_text:
		$Server/SnakeSize/LineEdit.text = str(Settings.SNAKE_SIZE)
