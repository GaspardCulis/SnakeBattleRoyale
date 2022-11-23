extends Control

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	
	$CanvasLayer/Label.text = Network.self_ip_address
	$Multiplayer_configure/server_ip.text = Network.server_ip_address
	$Multiplayer_configure/server_port.text = str(Network.port)
	
	Global.TILE_SIZE = Settings.SNAKE_SIZE
	
	$Multiplayer_configure/Create_server.grab_focus()
	$Multiplayer_configure/SnakeColor.set_HSlider_value(Settings.SNAKE_COL_SLIDER)

func _player_connected(id):
	print("Player "+str(id)+" connected")
	
func _player_disconnected(id):
	print("Player "+str(id)+" disconnected")
	
func _connected_to_server():
	print("Connected to server")
	get_tree().change_scene("res://scenes/PlaySpace/PlaySpace.tscn")
	
func _connection_failed():
	print('nah')
	if not $MultiplayerConfigure.visible:
		$Error.visible = true
	
func _server_disconnected():
	print('nope')

var tried_connection = false
func _on_Create_server_pressed():
	var color = $Multiplayer_configure/SnakeColor.color
	
	$Multiplayer_configure.hide()
	Network.create_server()
	Settings.snake_color = color
	get_tree().change_scene("res://scenes/PlaySpace/PlaySpace.tscn")
	tried_connection = true


func _on_Join_server_pressed():
	var color = $Multiplayer_configure/SnakeColor.color
	if $Multiplayer_configure/server_ip.text != "":
		$Multiplayer_configure.hide()
		Network.server_ip_address = $Multiplayer_configure/server_ip.text
		Network.port = int($Multiplayer_configure/server_port.text)
		Network.join_server()
		Settings.snake_color = color
		tried_connection = true
		

func _on_Back_pressed():
	if tried_connection:
		get_tree().change_scene("res://scenes/Network_setup/Network_setup.tscn")
		tried_connection = false
	else:
		get_tree().change_scene("res://scenes/TitleScreen/TitleScreen.tscn")


func _on_ConnectionTimeout_timeout():
	pass

func _on_SnakeColor_value_changed(new_value):
	Settings.SNAKE_COL_SLIDER = new_value
	Settings.save()
