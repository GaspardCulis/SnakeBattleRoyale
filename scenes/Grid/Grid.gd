tool
extends Node2D

export var TILE_SIZE:Vector2 = Vector2(10, 10)
export var THICNESS:int = 2
export var COLOR:Color = Color(0.7,0.7,0.7)



func _draw():
	var screen_size = get_viewport_rect().size
	
	for x in range(0, screen_size.x, TILE_SIZE.x):
		draw_line(Vector2(x, 0), Vector2(x, screen_size.y), COLOR)
	for y in range(0, screen_size.y, TILE_SIZE.y):
		draw_line(Vector2(0, y), Vector2(screen_size.x, y), COLOR)

func _process(delta):
	update()
