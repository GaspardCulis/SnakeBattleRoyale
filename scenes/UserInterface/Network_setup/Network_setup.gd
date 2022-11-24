extends Control

onready var SnakeColorInput = $Multiplayer_configure/ColorPicker
onready var ServerIpInput = $Multiplayer_configure/server_ip
onready var ServerPortInput = $Multiplayer_configure/server_port
onready var CreateServerButton = $Multiplayer_configure/Create_server

onready var IpAddressLabel = $CanvasLayer/Label

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	
	IpAddressLabel.text = Network.self_ip_address
	ServerIpInput.text = Network.server_ip_address
	ServerPortInput.text = str(Network.port)
	
	Global.TILE_SIZE = Settings.SNAKE_SIZE
	
	CreateServerButton.grab_focus()
	SnakeColorInput.set_color_slide(Settings.SNAKE_COL_SLIDER)

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
	var color = SnakeColorInput.color
	
	$Multiplayer_configure.hide()
	Network.create_server()
	Settings.snake_color = color
	get_tree().change_scene("res://scenes/PlaySpace/PlaySpace.tscn")
	tried_connection = true


func _on_Join_server_pressed():
	var color = SnakeColorInput.color
	if ServerIpInput.text != "":
		$Multiplayer_configure.hide()
		Network.server_ip_address = ServerIpInput.text
		Network.port = int(ServerPortInput.text)
		Network.join_server()
		Settings.snake_color = color
		tried_connection = true
		

func _on_Back_pressed():
	if tried_connection:
		get_tree().change_scene("res://scenes/UserInterface/Network_setup/Network_setup.tscn")
		tried_connection = false
	else:
		get_tree().change_scene("res://scenes/UserInterface/TitleScreen/TitleScreen.tscn")


func _on_ConnectionTimeout_timeout():
	pass

func _on_SnakeColor_value_changed(new_value):
	Settings.SNAKE_COL_SLIDER = new_value
	Settings.save()
