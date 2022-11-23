extends Node2D

export var SNAKE_SPEED:float = 0.07
export var GROW_RATE:int = 5

func processApples(snake):
	for node in get_parent().get_children():
		if node.name=="Apple":
			if snake.checkApple(node.pos):
				node.changePlace

func forward_snakes():
	var bodies:Array = []
	for i in range(3):
		for child in get_children():
			if child.name=="Snake":
				if i==0 and child.alive:
					child.forward()
					child.update()
					child.tookInput = false
					processApples(child)
				elif i==1:
					bodies+=child.tail
				elif i==2:
					child.alive = child.alive and not child.checkImpact(bodies)

func _process(delta):
	if not $Timer.time_left:
		forward_snakes()
		$Timer.start(SNAKE_SPEED)
		
func _ready():
	$Timer.one_shot = true
