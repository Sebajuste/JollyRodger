extends Label



onready var capture_zone = owner


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if capture_zone.capturing:
		
		var timer : Timer = capture_zone.get_node("CaptureTimer")
		
		var t := timer.wait_time - timer.time_left
		var p := (t / timer.wait_time) * 100
		
		self.text = str(int( p )) + " %"
		
	
	pass
