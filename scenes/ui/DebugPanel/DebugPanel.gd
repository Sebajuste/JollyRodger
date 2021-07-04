extends VBoxContainer




export var boat_path : NodePath


onready var boat := get_node(boat_path)



# Called when the node enters the scene tree for the first time.
func _ready():
	
	_on_Gravity_value_changed( ProjectSettings.get_setting("physics/3d/default_gravity") )
	$ControlList/Gravity/HSlider.value = ProjectSettings.get_setting("physics/3d/default_gravity")
	
	if boat:
		$ControlList/Mass/HSlider.value = boat.mass
		$ControlList/Mass/Value.text = str(boat.mass)
		
		$ControlList/BoatVelocityDamp/HSlider.value = boat.linear_damp
		$ControlList/BoatVelocityDamp/Value.text = str(boat.linear_damp)
		
		$ControlList/BoatAngularDamp/HSlider.value = boat.angular_damp
		$ControlList/BoatAngularDamp/Value.text = str(boat.angular_damp)
		
		$ControlList/BoatRudderForce/HSlider.value = boat.rudder_force
		$ControlList/BoatRudderForce/Value.text = str(boat.rudder_force)
		
		$ControlList/BoatSailForce/HSlider.value = boat.sail_force
		$ControlList/BoatSailForce/Value.text = str(boat.sail_force)
		
		$ControlList/FloaterWaterDrag/HSlider.value = boat.water_drag
		$ControlList/FloaterWaterDrag/Value.text = str(boat.water_drag)
		
		$ControlList/FloaterAngularDrag/HSlider.value = boat.water_angular_drag
		$ControlList/FloaterAngularDrag/Value.text = str(boat.water_angular_drag)
		
		$ControlList/DepthBeforeSumberged/HSlider.value = boat.depth_before_submerged
		$ControlList/DepthBeforeSumberged/Value.text = str(boat.depth_before_submerged)
		
		$ControlList/DisplacementAmount/HSlider.value = boat.displacement_amount
		$ControlList/DisplacementAmount/Value.text = str(boat.displacement_amount)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Gravity_value_changed(value):
	$ControlList/Gravity/Value.text = str(value)
	ProjectSettings.set_setting("physics/3d/default_gravity", value)


func _on_Mass_value_changed(value):
	$ControlList/Mass/Value.text = str(value)
	for boat in get_tree().get_nodes_in_group("water_boat"):
		boat.mass = value


func _on_BoatVelocityDamp_value_changed(value):
	$ControlList/BoatVelocityDamp/Value.text = str(value)
	for boat in get_tree().get_nodes_in_group("water_boat"):
		boat.linear_damp = value


func _on_BoatAngularDamp_value_changed(value):
	$ControlList/BoatAngularDamp/Value.text = str(value)
	for boat in get_tree().get_nodes_in_group("water_boat"):
		boat.angular_damp = value


func _on_BoatRudderForce_value_changed(value):
	$ControlList/BoatRudderForce/Value.text = str(value)
	for boat in get_tree().get_nodes_in_group("water_boat"):
		boat.rudder_force = value


func _on_BoatSailForce_value_changed(value):
	$ControlList/BoatSailForce/Value.text = str(value)
	for boat in get_tree().get_nodes_in_group("water_boat"):
		boat.sail_force = value



func _on_FloaterWaterDrag_value_changed(value):
	$ControlList/FloaterWaterDrag/Value.text = str(value)
	for floater in get_tree().get_nodes_in_group("water_floater"):
		floater.water_drag = value


func _on_FloaterAngularDrag_value_changed(value):
	$ControlList/FloaterAngularDrag/Value.text = str(value)
	for floater in get_tree().get_nodes_in_group("water_floater"):
		floater.water_angular_drag = value


func _on_DepthBeforeSumberged_value_changed(value):
	$ControlList/DepthBeforeSumberged/Value.text = str(value)
	for floater in get_tree().get_nodes_in_group("water_floater"):
		floater.depth_before_submerged = value
	


func _on_DisplacementAmount_value_changed(value):
	$ControlList/DisplacementAmount/Value.text = str(value)
	for floater in get_tree().get_nodes_in_group("water_floater"):
		floater.displacement_amount = value


func _on_ShowWater_toggled(button_pressed):
	for water in get_tree().get_nodes_in_group("water_mesh"):
		water.visible = button_pressed



func _on_ShowHideButton_pressed():
	
	$ControlList.visible = not $ControlList.visible
	


func _on_WaveDirectionX_value_changed(value):
	$ControlList/WaveDirection/Value.text = str("[%0.01f, %0.01f]" % [value, $ControlList/WaveDirection/VBoxContainer/WaveDirectionY/HSlider.value ])
	for water in get_tree().get_nodes_in_group("water_mesh"):
		water.wave_direction = Vector2(
			value,
			water.wave_direction.y
		)


func _on_WaveDirectionY_value_changed(value):
	$ControlList/WaveDirection/Value.text = str("[%0.01f, %0.01f]" % [$ControlList/WaveDirection/VBoxContainer/WaveDirectionX/HSlider.value, value ])
	for ocean in get_tree().get_nodes_in_group("water_mesh"):
		ocean.wave_direction = Vector2(
			ocean.wave_direction.x,
			value
		)


func _on_Steepness_value_changed(value):
	$ControlList/Steepness/Value.text = str(value)
	
	for ocean in get_tree().get_nodes_in_group("water_mesh"):
		ocean.steepness = value


func _on_wavelength_value_changed(value):
	$ControlList/WaveLength/Value.text = str(value)
	
	for ocean in get_tree().get_nodes_in_group("water_mesh"):
		ocean.amplitude = value



