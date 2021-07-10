extends Spatial


var floater_count := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for child in get_children():
		if child is WaterFloater:
			floater_count += 1
	
	for child in get_children():
		if child is WaterFloater:
			child.floater_count = floater_count
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


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
	

