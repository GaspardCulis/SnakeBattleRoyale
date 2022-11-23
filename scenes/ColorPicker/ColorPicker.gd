extends Panel

var color:Color = Color(255, 0, 0)

signal value_changed(new_value)

func _ready():
	$Preview/Color.color = color

func _on_HSlider_value_changed(value):
	value = clamp(value, 5, 95)
	set_HSlider_value(value)
	
	color = $ColorGradient.texture.gradient.interpolate(value/100.0)
	$Preview/Color.color = color
	emit_signal("value_changed", value)

func set_HSlider_value(value:int):
	$HSlider.value = value
