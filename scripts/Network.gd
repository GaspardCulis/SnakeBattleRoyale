extends Node

var server = null
var client = null

var self_ip_address := ""
var server_ip_address = "178.79.148.7"
var port = 4444
var max_clients = 6

func _ready():
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168") or ip.begins_with("10.") or ip.begins_with("172.16"):
			self_ip_address = ip
		
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func create_server():
	server = NetworkedMultiplayerENet.new()
	server.create_server(port, max_clients)
	get_tree().set_network_peer(server)

func join_server():
	client = NetworkedMultiplayerENet.new()
	client.create_client(server_ip_address, port)
	get_tree().set_network_peer(client)

func _connected_to_server():
	pass
	print("Connecté au serveur")
	
func _server_disconnected():
	print("Deconnecté du serveur")
