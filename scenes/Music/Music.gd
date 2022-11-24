extends AudioStreamPlayer

const NO_MUSIC_BCZ_LAW = false

var titles = ["LEO", "DOOMROAR", "HYPERLIPS", "SHAP3S"]
var old_title:String

func _ready():
	randomize()
	if not (OS.has_feature("Server") or NO_MUSIC_BCZ_LAW):
		play()
	
	
func play(_u: float = 0):
	var index = randi()%len(titles)
	while titles[index]==old_title:
		index = randi()%len(titles)
	
	self.stream = load("res://assets/musics/"+titles[index]+".ogg")
	old_title = titles[index]
	print('Playing '+titles[index])
	.play()
	
	

func pause():
	self.stream_paused = true
	
func resume():
	self.stream_paused = false
