extends ShipState


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func enter(_msg := {}):
	
	_parent.chosen_direction = Vector3.ZERO
	


func process(_delta):
	
	#print("[%s] idle ai process" % ship.name)
	pass
