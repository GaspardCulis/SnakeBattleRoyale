extends Node


var cycle:Array

func _ready():
	pass
	
func generateDefaultCycle(size_x, size_y):
	var out:Array
	
	
	for x in range(size_x):
		if x%2:
			for y in range(size_y):
				out.append(Vector2(x, y))
		else:
			for y in range(size_y):
				out.append(Vector2(x, y))
