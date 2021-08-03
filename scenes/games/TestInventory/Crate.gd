extends RigidBody



onready var inventory := $Inventory


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_LifeTimer_timeout():
	
	$SinkTween.interpolate_property($Floater, "displacement_amount",
		$Floater.displacement_amount, 0.0, 60.0,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$SinkTween.start()
	
	$ClearTimer.start()
	


func _on_Inventory_inventory_updated(items):
	
	$SinkTimer.start()
	


func _on_ClearTimer_timeout():
	
	queue_free()
	
