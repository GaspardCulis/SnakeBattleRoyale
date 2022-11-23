tool
extends Node2D

export var COLOR:Color = Color(1.0,0.0,0.0)
export var RESPAWN_TIME:float = 1.0
export var FADE_TIME:float = 1.0

onready var SIZE:int = Global.TILE_SIZE

var movingProcess = false
var pos:Vector2 = Vector2(0,0)
var newPos:Vector2
var ID

func changePlace(force = false, bodies = []):
	if not len(bodies):
		newPos = Vector2(randi()%int(get_viewport_rect().size.x/SIZE), randi()%int(get_viewport_rect().size.y/SIZE))*Global.TILE_SIZE
	else:
		newPos = Global.find_valid_spawn_pos(bodies)*Global.TILE_SIZE
	
	if force:
		position = newPos
		return
	$BoxParticles.emit_particles_one_shot(COLOR)
	movingProcess = true
	COLOR.a = 0.0
	update()
	$Timer.start(RESPAWN_TIME)
	
var fadingProcess = false
func _process(delta):
	if fadingProcess:
		COLOR.a += delta*FADE_TIME
		if COLOR.a>=1.0:
			COLOR.a = 1.0
			fadingProcess = false
		update()
			
func _draw():
	draw_rect(Rect2(pos.x * SIZE, pos.y * SIZE, SIZE, SIZE), COLOR)

func _ready():
	$Timer.one_shot = true
	$BoxParticles.position = Vector2.ONE*Global.TILE_SIZE/2
	visible = true
	ID = get_parent().get_child_count()


func _on_Timer_timeout():
	position = newPos
	movingProcess = false
	fadingProcess = true
