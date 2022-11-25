extends Node2D

var screen_size
var play_size
var DEFAULT_GROW:int = 3

var Snake = load("res://scenes/Snake/Snake.tscn")
var Apple = load("res://scenes/Apple/Apple.tscn")
var BoxParticles = load("res://scenes/BoxParticles/BoxParticles.tscn")
var CoolText = load("res://scenes/CoolText/CoolText.tscn")


# --------------------------------------------------------------------------
#                           ACTUAL GAME
# --------------------------------------------------------------------------

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	randomize()
	$SnakesTimer.one_shot = false
	screen_size = get_viewport().size
	play_size = screen_size/Global.TILE_SIZE
	$PauseMenu.visible = false
	$ServerClosed.visible = false
	
	
	if is_network_master():
		if not OS.has_feature("Server"):
			var snake = Global.instance_node(Snake, $Snakes)
			snake.ID = get_tree().get_network_unique_id()
			snake.COLOR = Settings.snake_color
			snake.tail[0] = Global.find_valid_spawn_pos(get_bodies())
			snake.connect("finished_dying_process", self, "_on_Snake_dead")
			snake.grow(DEFAULT_GROW)
		
		var apple = Global.instance_node(Apple, $Apples)
		apple.changePlace(true)
	else:
		rpc("throw_login_info", Settings.snake_color)
	
	$SnakesTimer.start()

func get_snake_by_id(id):
	for snake in $Snakes.get_children():
		if snake.ID == id:
			return snake
	return false
	
func get_apple_by_id(id):
	for apple in $Apples.get_children():
		if apple.ID == id:
			return apple
	return false

func get_bodies(apples = true) -> Array:
	var bodies = []
	for snake in $Snakes.get_children():
		bodies+=snake.tail
	if apples:
		for apple in $Apples.get_children():
			bodies.append(apple.position/Global.TILE_SIZE)
	return bodies

func checkApples(snake, bodies):
	for apple in $Apples.get_children():
		if snake.checkApple(apple.position) and not apple.movingProcess:
			snake.grow(Settings.GROW_RATE)
			apple.changePlace(false, bodies)
			rpc_unreliable("set_apple_fading_process", apple.ID, apple.newPos)

func get_killer(bodies:Array, victim:Object):
	var killer:Object
	for suspect in $Snakes.get_children():
		if suspect.ID==victim.ID:continue
		if suspect.tail.count(victim.tail[0]+victim.direction):
			killer = suspect
			break

	# Creating kill text
	if not killer:return
	var my_text = Global.instance_node(CoolText, $DeathTexts)
	my_text.position = victim.tail[0]*Global.TILE_SIZE + Vector2.ONE*Global.TILE_SIZE/2
	my_text.setColor(killer.COLOR)
	if is_network_master():
		rpc_unreliable("new_death_message", my_text.position, my_text.getText(), killer.COLOR)

func old_forward_snakes():
	var old_bodies:Array = []
	var new_bodies:Array = []
	
	for i in range(3):
		for child in $Snakes.get_children():
			if i==0:
				old_bodies+=child.tail
			elif i==1 and child.alive:
				var old_alive = child.alive
				var collided = child.checkImpactBeforeDrama(old_bodies) or child.checkImpact(old_bodies)
				child.alive = (child.alive and not (collided or Global.isPosOut(child.tail[0]+child.direction))) or Settings.CHILL
				if collided:
					get_killer(old_bodies, child)
				if child.alive:
					child.forward()
					child.update()
					child.tookInput = false
				elif old_alive:
					child.start_dying_process()
				new_bodies+=child.tail
			elif i==2 and child.alive:
				pass
				#processApples(child, new_bodies)

func forward_snakes():
	var bodies = get_bodies(false)
	
	var snakes = $Snakes.get_children()
	snakes.shuffle()   # Bcz else will give advantage to lowest index snakes
	for snake in snakes:
		var old_alive = snake.alive
		var collided = snake.checkImpactBeforeDrama(bodies) or snake.checkImpact(bodies)
		snake.alive = snake.alive and not(collided or Global.isPosOut(snake.tail[0]+snake.direction)) or Settings.CHILL
		
		if snake.alive:
			snake.forward()
			snake.tookInput = false
			checkApples(snake, bodies)
		elif old_alive:  # Snake just died
			snake.start_dying_process()
			get_killer(bodies, snake)
		
	
	
	
	

func _on_SnakesTimer_timeout():
	if is_network_master():
		forward_snakes()
		handleMultiplayer()
		$SnakesTimer.start(Settings.SPEED)

func _on_Snake_dead(id):
	if Settings.RESPAWN:
		var my_snake = get_snake_by_id(id)
		my_snake.alive = true
		my_snake.tail = [Global.find_valid_spawn_pos(get_bodies())]
		my_snake.tookInput = false
		my_snake.direction = Vector2.ZERO
		my_snake.grow(DEFAULT_GROW)
		createParticles(my_snake.tail[0], my_snake.COLOR)
		if not(is_network_master() and my_snake.ID==get_tree().get_network_unique_id()):
			rpc_id(my_snake.ID, "force_set_snake_direction", Vector2.ZERO)
		rpc_unreliable("create_death_particles", my_snake.tail[0], my_snake.COLOR)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		togglePauseMenu()

func _on_Resume_pressed():
	$PauseMenu.visible = false

func _on_Disconnect_pressed():
	get_tree().network_peer.close_connection()
	get_tree().change_scene("res://scenes/UserInterface/Network_setup/Network_setup.tscn")

func _on_Quit_pressed():
	Settings.save()
	get_tree().quit()
	
func _on_ServerDead_Button_pressed():
	get_tree().change_scene("res://scenes/UserInterface/Network_setup/Network_setup.tscn")

func togglePauseMenu():
	$PauseMenu.visible = not $PauseMenu.visible
	
func createParticles(pos,color):
	var my_particles = Global.instance_node(BoxParticles, $Particles)
	my_particles.global_position = pos*Global.TILE_SIZE + Vector2.ONE*Global.TILE_SIZE/2
	my_particles.emit_particles_one_shot(color)
	
func _notification(what):  # Android back button
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
		togglePauseMenu()

# --------------------------------------------------------------------------
#                           NETWORKING
# --------------------------------------------------------------------------


func _player_connected(id):
	if not is_network_master():return
	print("Player "+str(id)+" connected")
	var snake = Global.instance_node(Snake, $Snakes)
	snake.ID = id
	snake.tail[0] = Global.find_valid_spawn_pos(get_bodies())
	snake.grow(DEFAULT_GROW)
	snake.connect("finished_dying_process", self, "_on_Snake_dead")
	rpc_id(id, "setTileSize", Global.TILE_SIZE)
	
	
	
func _player_disconnected(id):
	print("Player "+str(id)+" disconnected")
	var my_snake = get_snake_by_id(id)
	for pos in my_snake.tail:
		createParticles(pos, my_snake.COLOR)
	
	rpc("snake_disconnected",my_snake.tail, my_snake.COLOR)
	my_snake.queue_free()
	return

func _server_disconnected():
	print('server go yeeet')
	$ServerClosed.visible = true

var particleQueue:Array
func handleMultiplayer():
	if !is_network_master():return
	
	var snakes:Array
	var new_particles:Array
	for snake in $Snakes.get_children():
		new_particles+=snake.handle_dying_return_particles_pos()
		var my_info = {"ID":snake.ID, "tail":snake.tail, "color":snake.COLOR}
		snakes.append(my_info)
	
	var apples:Array
	for apple in $Apples.get_children():
		var my_info = {"ID":apple.ID, "pos":apple.position}
		apples.append(my_info)
	
	rpc_unreliable("get_data", snakes, apples, new_particles)
	for particle in new_particles:
		createParticles(particle['pos'], particle['color'])


remote func throw_login_info(color):  # sent by client
	if not is_network_master():return
	
	for snake in $Snakes.get_children():
		if snake.ID==get_tree().get_rpc_sender_id():
			snake.COLOR = color

remote func get_data(snakes:Array, apples:Array, new_particles:Array): # encoded like that : {"ID":snake.ID, "tail":snake.tail, "color":snake.COLOR} , sent by server
	if is_network_master():return

	for snake in snakes:
		var my_snake = get_snake_by_id(snake["ID"])
		if not my_snake:
			my_snake = Global.instance_node(Snake, $Snakes)
			my_snake.ID = snake["ID"]
		
		my_snake.tail = snake["tail"]
		my_snake.COLOR = snake["color"]
		my_snake.update()
	
	for apple in apples:
		var my_apple = get_apple_by_id(apple["ID"])
		if not my_apple:
			my_apple = Global.instance_node(Apple, $Apples)
			my_apple.ID = apple["ID"]
		
		my_apple.position = apple["pos"]
		my_apple.update()
		
	for particle in new_particles:
		createParticles(particle['pos'],particle['color'])
	# INPUTS
	var mah_snake = get_snake_by_id(get_tree().get_network_unique_id())
	if mah_snake.tookInput:
		rpc_id(1, "set_snake_direction", mah_snake.direction)
	mah_snake.tookInput = false
	

remote func set_snake_direction(direction:Vector2):   # sent by client
	if not is_network_master():return
	
	var my_snake = get_snake_by_id(get_tree().get_rpc_sender_id())
	if my_snake.direction+direction!=Vector2.ZERO and not my_snake.tookInput:
		my_snake.direction = direction
		my_snake.tookInput = true
	else:
		rpc_id(get_tree().get_rpc_sender_id(), "force_set_snake_direction", my_snake.direction)
		my_snake.tookInput = true

remote func force_set_snake_direction(direction:Vector2):   # sent by server
	if is_network_master():return
	
	get_snake_by_id(get_tree().get_network_unique_id()).direction = direction



remote func snake_disconnected(tail:Array, color:Color):   # Sent by server
	for body in tail:
		createParticles(body, color)

remote func set_apple_fading_process(id, newPos):  # sent by server
	if is_network_master():return
	
	var my_apple = get_apple_by_id(id)
	if not my_apple:
		print("error occured at set_apple_fading_process")
		return
	my_apple.get_node("BoxParticles").emit_particles_one_shot(my_apple.COLOR)
	my_apple.movingProcess = true
	my_apple.COLOR.a = 0.0
	my_apple.newPos = newPos
	my_apple.get_node("Timer").start(my_apple.RESPAWN_TIME)
	my_apple.update()

remote func create_death_particles(pos, color):  # sent by server
	if is_network_master():return
	print("zaza")
	createParticles(pos,color)

remote func new_death_message(position, text, color):  # sent by server
	if is_network_master():return
	var my_text = Global.instance_node(CoolText, $DeathTexts)
	my_text.position = position
	my_text.setColor(color)
	my_text.setText(text)
	
remote func setTileSize(size:int):  # Sent by server
	if is_network_master():return
	Global.setTileSize(size)
	
	
	
# ------------------------------
#            DEBUG 
# ------------------------------

func _draw():
	draw_rect(Rect2(Vector2.ZERO, Global.play_size*Global.TILE_SIZE), Color('#1f1f1f'))
	draw_rect(Rect2(Vector2.ZERO, Global.play_size*Global.TILE_SIZE), Color('#2e2e2e'), false, Global.TILE_SIZE)
