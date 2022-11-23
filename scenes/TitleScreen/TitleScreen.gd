extends Control


var angle:float = 0;
func _process(delta):
	$Title.rect_rotation = sin(deg2rad(angle))*10
	angle = fmod(angle + 30*delta, 360)
	
	

func _on_Play_pressed():
	get_tree().change_scene("res://scenes/Network_setup/Network_setup.tscn")


func _on_Settings_pressed():
	get_tree().change_scene("res://scenes/Settings/Settings.tscn")

func _ready():
	if OS.has_feature("Server"):
		Network.create_server()
		Global.snake_color = Color(0,255,0)
		print("Starting server for SnakeBattleRoyale "+Global.VERSION)
		get_tree().change_scene("res://scenes/PlaySpace/PlaySpace.tscn")
	FPS.visible = Settings.SHOW_FPS
	Global.TILE_SIZE = Settings.SNAKE_SIZE
	$Version.text = Global.VERSION
	
	$Play.grab_focus()


func _on_Exit_pressed():
	Settings.save()
	get_tree().quit()
