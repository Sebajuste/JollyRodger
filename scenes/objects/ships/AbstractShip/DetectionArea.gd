extends Area


signal ennemy_entered(ship)


var ships_detected := []



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_ennemies() -> Array:
	var ennemies := []
	for index in range(ships_detected.size()-1, -1, -1):
		var ship_ref : WeakRef = ships_detected[index]
		var ship = ship_ref.get_ref()
		if ship and ship.alive:
			if _is_ennemy_ship(ship):
				ennemies.append(ship)
		else:
			ships_detected.remove(index)
	return ennemies


func get_allies() -> Array:
	var allies :=[]
	for ship_ref in ships_detected:
		var ship = ship_ref.get_ref()
		if ship and ship.flag.faction == owner.flag.faction:
			allies.append(ship)
	return allies


func ship_detected(ship) -> bool:
	for detected_ref in ships_detected:
		if detected_ref.get_ref() == ship:
			return true
	return false


func _is_ennemy_ship(ship):
	if ship.flag.faction != "" and ship.flag.faction != "None" and ship.flag.faction != owner.flag.faction:
		return true
	return false


func _on_DetectionArea_body_entered(body):
	if body == owner:
		return
	if body.is_in_group("ship") and not ship_detected(body):
		print("[%s] ship detected : %s" % [owner.name, body.name])
		ships_detected.append(weakref(body))
		if _is_ennemy_ship(body):
			emit_signal("ennemy_entered", body)


func _on_DetectionArea_body_exited(body):
	for index in range(ships_detected.size()):
		var ship_ref = ships_detected[index]
		if ship_ref.get_ref() == body:
			ships_detected.remove(index)
