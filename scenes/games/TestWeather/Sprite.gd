extends ColorRect

#udate uniforms

var iTime := 0.0
#var iFrame := 0
var sun_dir := Vector3(-1, 0, 0)
var sun_color := Color(1.0, 0.7, 0.55) setget set_sun_color


func _ready():
	
	pass



func _process(delta):
	iTime += delta
	#iFrame += 1
	
	self.material.set("shader_param/iTime", iTime)
	#self.material.set("shader_param/iFrame", iFrame)
	
	#sun_dir.rotated(Vector3.UP, delta*100)
	
	self.material.set("shader_param/sun_dir", sun_dir.normalized())
	
	pass

func cov_scb(value):
	print("coverage : ", value)
	self.material.set("shader_param/COVERAGE",float(value)/100)

func absb_scb(value):
	print("absorption : ", value)
	self.material.set("shader_param/ABSORPTION",float(value)/10)

func thick_scb(value):
	print("thickness : ", value)
	self.material.set("shader_param/THICKNESS",value)

func step_scb(value):
	print("step : ", value)
	self.material.set("shader_param/STEPS",value)

func set_sun_color(value):
	
	self.material.set("shader_param/sun_color", value)
	
