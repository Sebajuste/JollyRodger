class_name ShipState
extends State


var ship : AbstractShip


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(self.owner, "ready")
	ship = owner


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
