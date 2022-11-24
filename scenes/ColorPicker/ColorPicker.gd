extends Panel

var color:Color = Color(255, 0, 0)

signal value_changed(new_value)

onready var ColorGradient := $VBoxContainer/ColorGradient
onready var PreviewTexture := $Preview/Color

func _ready():
	PreviewTexture.color = color

func set_color_slide(value:int):
	value = clamp(value, 5, 95)
	color = ColorGradient.texture.gradient.interpolate(value/100.0)
	PreviewTexture.color = color
	emit_signal("value_changed", value)


func _on_ColorGradient_gui_input(event):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(1):
			set_color_slide((event.position.x / ColorGradient.rect_size.x)*100)
