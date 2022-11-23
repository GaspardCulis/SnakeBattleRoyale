extends Node2D

func _ready():
	set_global_position(Vector2(get_viewport().size.x - $Label.rect_size.x, 0))
	self.visible = false

func _process(delta):
	$Label.text = "FPS : "+str(int(1.0/delta))
