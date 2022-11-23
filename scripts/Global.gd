extends Node

const VERSION = "v1.5"

var TILE_SIZE:int = 40
onready var play_size = get_viewport().size/TILE_SIZE

func setTileSize(new_size:int):
	TILE_SIZE = new_size
	play_size = get_viewport().size/TILE_SIZE

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

func find_valid_spawn_pos(bodies:Array, min_distance = max(play_size.x, play_size.y)/10) -> Vector2:
	var max_tries = 20
	var spawn_pos
	var done = false
	var i = 0
	while not done and i<max_tries:
		spawn_pos = Vector2(randi()%int(play_size.x), randi()%int(play_size.y))
		done = true
		for body in bodies:
			if body.distance_to(spawn_pos)<min_distance:
				done = false
		i+=1
	if not done:
		if min_distance==0:
			print("What the heck ?")
			return Vector2.ZERO
		return find_valid_spawn_pos(bodies, min_distance-1)
		
	return spawn_pos

func isPosOut(pos:Vector2) -> bool:
	return pos.x<0 or pos.y<0 or pos.x>=Global.play_size.x or pos.y>=Global.play_size.y

func setScreenSize():
	var new_size:Vector2 = Vector2.ZERO
	var size_text = Settings.SCREEN_SIZE
	if size_text.to_lower()!='fullscreen':
		OS.window_fullscreen = false
		new_size.x = (size_text.split('x')[0]).to_int()
		new_size.y = (size_text.split('x')[1]).to_int()
		OS.window_size = new_size
	else:
		OS.window_fullscreen = true
