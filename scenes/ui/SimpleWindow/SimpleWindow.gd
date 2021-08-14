class_name SimpleWindow
extends Control



export(NodePath) var ship_path


onready var ship : AbstractShip = get_node(ship_path) if has_node(ship_path) else null


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func open():
	
	$AnimationPlayer.play("fade_in")
	


func close():
	
	$AnimationPlayer.play("fade_out")
	
