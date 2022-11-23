extends Node2D

export var COLOR:Color = Color(0.0, 1.0, 0.0)
export var SPEED:float = 0.05
export var RESPAWN_DELAY:float = 10.0

var headless = false

var alive:bool = false
var direction:Vector2 = Vector2(0,0)
var tail:Array = [Vector2(0,0)]

var grow_queue:int = 0

var ID
var kills:int

signal finished_dying_process(id)

func setPos(newPos:Vector2):
	var diff = newPos - tail[0]
	for i in range(len(tail)):
		tail[i]+=diff

func forward():
	var newPos = tail[0]
	tail[0] += direction
	for i in range(1, len(tail)):
		var temp = tail[i]
		tail[i] = newPos
		newPos = temp
	if grow_queue>0 and direction:
		tail.append(newPos)
		grow_queue-=1
	update()
	tookInput = false


func grow(units:int = 1):
	grow_queue+=units

var mouse_pressed := false
var mouse_click_pos: Vector2
var touchscreen_mode := false
func _input(event):
	# For touchscreen
	if event is InputEventScreenTouch:
		if event.is_pressed():
			mouse_pressed = true
			mouse_click_pos = event.position
			touchscreen_mode = true
		else:
			mouse_pressed = false
	

func handleInputs() -> bool:
	# Keybloard
	var out:bool = false
	if Input.is_action_pressed("ui_right") and not direction.x:
		direction = Vector2(1,0)
		out = true
	elif Input.is_action_pressed("ui_left") and not direction.x:
		direction = Vector2(-1,0)
		out = true
	elif Input.is_action_pressed("ui_up") and not direction.y:
		direction = Vector2(0,-1)
		out = true
	elif Input.is_action_pressed("ui_down") and not direction.y:
		direction = Vector2(0,1)
		out = true
	
	touchscreen_mode = not out and touchscreen_mode
	
	if touchscreen_mode and mouse_pressed:
		var diff:Vector2 = (get_global_mouse_position()-mouse_click_pos)
		
		var x_threshold = diff.length()/4
		var y_threshold = x_threshold
		
		
		if diff.x>0 and abs(diff.x)>x_threshold and not direction.x:
			direction = Vector2(1,0)
		elif diff.x<0 and abs(diff.x)>x_threshold and not direction.x:
			direction = Vector2(-1,0)
		elif diff.y>0 and abs(diff.y)>y_threshold and not direction.y:
			direction = Vector2(0,1)
		elif diff.y<0 and abs(diff.y)>y_threshold and not direction.y:
			direction = Vector2(0,-1)
		
		
		out = true
	
	return out

func checkImpact(bodies:Array) -> bool:
	return bodies.count(tail[0])>1

func checkImpactBeforeDrama(bodies:Array) -> bool:
	if direction!=Vector2.ZERO:
		return bodies.count(tail[0] + direction)>=1
	else:
		return bodies.count(tail[0] + direction)>1

func checkApple(applePos:Vector2) -> bool:
	return applePos.distance_to(tail[0]*Global.TILE_SIZE)<Global.TILE_SIZE

func _ready():
	alive = true
	$Timer.wait_time = SPEED
	$Timer.one_shot = true

var tookInput = false
func _process(delta):
	if self.headless:return
	if self.ID!=get_tree().get_network_unique_id():return
	# Inputs
	if not tookInput:
		tookInput = handleInputs()

func _draw():
	for i in range(len(tail)-1, -1, -1):
		draw_rect(Rect2(tail[i].x * Global.TILE_SIZE , tail[i].y * Global.TILE_SIZE , Global.TILE_SIZE, Global.TILE_SIZE), COLOR.darkened( 0*float(i)/float(len(tail)*1.5) ))

var on_dead_tail_len:int
var dying:bool = false
func start_dying_process():
	$DeathTimer.start(RESPAWN_DELAY)
	on_dead_tail_len = len(tail)
	dying = true
	grow_queue = 0

func handle_dying_return_particles_pos() -> Array:
	var out:Array
	if dying:
		while float(len(tail))/float(on_dead_tail_len) > $DeathTimer.time_left/float(RESPAWN_DELAY):
			out.append({'pos':self.tail.pop_back(), 'color':self.COLOR})
	if not len(self.tail):
		emit_signal("finished_dying_process", self.ID)
		self.dying = false
	if not headless:
		if is_network_master():
			self.update()
	else:
		self.update()
	return out
