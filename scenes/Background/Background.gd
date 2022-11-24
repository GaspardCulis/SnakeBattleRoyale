extends Control

export var BACKGROUND_COLOR:Color

var ColorGradient = load("res://resources/colorGradient.tres")
var Snake = load("res://scenes/Snake/Snake.tscn")
var BoxParticles = load("res://scenes/BoxParticles/BoxParticles.tscn")

const MAX_SNAKES:int = 10

func _ready():
	randomize()
	$Timer.wait_time = 0.07
	$Timer.start()
	
	for i in range(MAX_SNAKES):
		createNewSnake()

func get_bodies() -> Array:
	var out = []
	
	for snake in $Snakes.get_children():
		out+=snake.tail
	
	return out

func createNewSnake():
	var my_snake = Global.instance_node(Snake, $Snakes)
	my_snake.setPos(Global.find_valid_spawn_pos(get_bodies()))
	
	my_snake.direction = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT][randi()%4]
	my_snake.COLOR = ColorGradient.interpolate(randf())
	my_snake.headless = true
	
	my_snake.grow(randi()%50 + 5)
	



func getImpactDirs(snake:Object, bodies:Array, depth:int=2):
	var out:Array
	for j in range(depth, 0, -1):
		var new_out:Array
		for i in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
			if (bodies.count(snake.tail[0]+ i*j) or Global.isPosOut(snake.tail[0]+ i*j)) and not out.count(i):
				new_out.append(i)
		if len(out+new_out)>=4:out=new_out
		else:out+=new_out
	return out
	
		
	return out

func processSnakes():
	var bodies = get_bodies()
	forward_snakes(bodies)
	for snake in $Snakes.get_children():
		if not len(snake.tail):
			snake.queue_free()
			continue
		if Global.isPosOut(snake.tail[0]) and not snake.dying:
			snake.alive = false
			snake.start_dying_process()
		if not snake.alive:
			if snake.dying:
				var particles_pos = snake.handle_dying_return_particles_pos()
				for pos in particles_pos:
					var my_particles = Global.instance_node(BoxParticles, snake.get_node("DeathParticles"))
					my_particles.position = pos['pos'] * Global.TILE_SIZE + Vector2.ONE*Global.TILE_SIZE/2
					my_particles.emit_particles_one_shot(pos['color'])
					snake.update()
			else:
				print(randf())
				snake.start_dying_process()
			continue
		var impactDirs = getImpactDirs(snake, bodies)
		if impactDirs.count(snake.direction):
			var possibleDirs = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
			for i in impactDirs:
				possibleDirs.erase(i)
			if len(possibleDirs):
				snake.direction = possibleDirs[randi()%len(possibleDirs)]
			else:
				print('Fuuucck im gonna die nooo i was so young')
			return
		
		if randf()<= 1.0/1.0*$Timer.wait_time:
			var new_dir = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT][randi()%4]
			var nb = 0
			while(new_dir+snake.direction == Vector2.ZERO or getImpactDirs(snake, get_bodies()).count(new_dir)) and nb<10:
				new_dir = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT][randi()%4]
				nb+=1
			snake.direction = new_dir

func forward_snakes(bodies:Array):
	
	for child in $Snakes.get_children():
		var old_alive = child.alive
		child.alive = child.alive and not child.checkImpactBeforeDrama(bodies) and not(child.checkImpact(bodies))
		if child.alive:
			child.forward()
		elif old_alive:
			child.start_dying_process()

func _process(delta):
	if randf()<= 1.0/4.0*delta:
		if $Snakes.get_child_count()<MAX_SNAKES:
			createNewSnake()


func _on_Timer_timeout():
	processSnakes()
