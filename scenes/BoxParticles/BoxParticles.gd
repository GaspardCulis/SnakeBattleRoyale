extends CPUParticles2D

export var autoYeet = true

func _ready():
	emission_rect_extents = Vector2.ONE * Global.TILE_SIZE
	scale_amount *= Global.TILE_SIZE/10
	initial_velocity *= Global.TILE_SIZE/10

var emitted = false
func emit_particles_one_shot(color:Color):
	self.color = color
	self.one_shot = true
	self.emitting = true
	self.emitted = true
	
func _process(delta):
	if emitted and not emitting and autoYeet:
		self.queue_free()
