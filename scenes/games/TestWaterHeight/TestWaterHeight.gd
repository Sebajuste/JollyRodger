extends Spatial



var SELECT_HINT_SCENE = preload("res://scenes/miscs/SelectHint/SelectHint.tscn")


onready var water_manager := $Ocean
onready var ship : RigidBody = $SwedishRoyalYachtAmadis

var target : RigidBody = null
var select_hint = null





# Called when the node enters the scene tree for the first time.
func _ready():
	
	"""
	var floaters := get_tree().get_nodes_in_group("water_floater")
	
	for floater in floaters:
		floater.water_manager = water_manager
	
	var floater_managers := get_tree().get_nodes_in_group("water_floater_manager")
	for floater_manager in floater_managers:
		floater_manager.water_manager = water_manager
	"""
	
	ObjectSelector.connect("object_selected", self, "_on_object_selected")
	
	Spawner.connect("on_node_emitted", self, "_on_node_emitted")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(_delta):
	
	$Cube.global_transform.origin.y = $Ocean.get_wave_height( $Cube.global_transform.origin )
	
	
	#var height : float = $WaterCos.get_height($Cube.global_transform.origin)
	#$Cube.global_transform.origin.y = height
	
	pass


func _input(event):
	
	if event is InputEventMouseButton:
		
		if event.button_index == BUTTON_LEFT:
			
			if select_hint:
				select_hint.queue_free()
				select_hint = null
			target = null
	


func _unhandled_input(event):
	if event.is_action_pressed("fire_order") and target:
		
		for canon in ship.get_node("Cannons").get_children():
			
			var target_pos := target.global_transform.origin
			var target_velocity := target.linear_velocity
			
			if canon.fire_ready and canon.is_in_range(target_pos):
				
				canon.fire_delay = rand_range(0.0, 0.5)
				
				canon.fire(target_pos, target_velocity)
			


func _on_object_selected(object):
	
	select_hint = SELECT_HINT_SCENE.instance()
	select_hint.offset = Vector3.UP * 20
	object.add_child(select_hint)
	
	target = object
	


func _on_node_emitted(node):
	
	add_child(node)
	
