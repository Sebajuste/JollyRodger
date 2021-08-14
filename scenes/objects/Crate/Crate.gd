extends RigidBody



onready var inventory := $Inventory


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SinkTimer_timeout():
	
	$AnimationPlayer.play("sink")
	


func sink(duration : float = 20):
	
	$SinkTween.interpolate_property($Floater, "displacement_amount",
		$Floater.displacement_amount, 0.0, duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$SinkTween.start()
	


func move_in_ground(duration : float = 5):
	var start_pos := global_transform
	var end_pos := Transform(global_transform)
	end_pos.origin = end_pos.origin + Vector3.DOWN * 5
	$SinkTween.interpolate_property(self, "global_transform",
		start_pos, end_pos, duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$SinkTween.start()


func _on_Inventory_inventory_updated(_items):
	
	$SinkTimer.start()
	
