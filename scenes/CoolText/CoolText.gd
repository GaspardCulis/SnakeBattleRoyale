extends Node2D

const death_texts = ['get rekt !','bruh.','yeet','u ded','+1 kill']

onready var base_angle = deg2rad(randi()%60 - 30)

func _ready():
	randomize()
	self.scale = Vector2.ZERO
	$CoolText.text = death_texts[randi()%len(death_texts)]

func setColor(color:Color):
	self.modulate = color

func setText(text:String):
	$CoolText.text = text
	
func getText():
	return $CoolText.text

var counter = 0
var angle_modifier = 0
func _process(delta):
	counter+=delta
	angle_modifier += delta * (randf()*6+1)*3

	rotation = base_angle + sin(angle_modifier)/2

	if scale.x>=1:
		scale = Vector2.ONE
	else :
		scale+=Vector2.ONE*delta*2
		
	if counter>1.5:
		self.modulate.a = max(self.modulate.a - delta*2 , 0)
		if self.modulate.a == 0:
			self.queue_free()
