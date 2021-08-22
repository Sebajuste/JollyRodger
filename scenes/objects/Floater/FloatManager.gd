extends Spatial


export var water_drag := 2.0 # 0.99
export var water_angular_drag := 2.0 # 0.5

export var depth_before_submerged := 2.5
export var displacement_amount := 0.5


var floater_count := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for child in get_children():
		if child is WaterFloater:
			floater_count += 1
	
	for child in get_children():
		if child is WaterFloater:
			child.water_drag = water_drag
			child.water_angular_drag = water_angular_drag
			child.depth_before_submerged = depth_before_submerged
			child.displacement_amount = displacement_amount
			child.floater_count = floater_count
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_water_volumic_mass() -> float:
	for child in get_children():
		if child is WaterFloater:
			if child.immerged:
				return child.get_water_volumic_mass()
	return 0.0


func is_in_water() -> bool:
	
	var floater_submerged_count := 0
	
	for child in get_children():
		if child is WaterFloater:
			if child.immerged:
				floater_submerged_count += 1
	
	if floater_submerged_count > floater_count / 2.0:
		return true
	
	return false


func set_displacement_amount(value):
	for child in get_children():
		if child is WaterFloater:
			child.displacement_amount = value


func sink(duration := 60):
	$SinkTween.interpolate_method(self, "set_displacement_amount",
		displacement_amount, 0.0, duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$SinkTween.start()
