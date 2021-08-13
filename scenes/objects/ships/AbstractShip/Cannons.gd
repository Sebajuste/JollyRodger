class_name AbstractShipCannonsHandler
extends Spatial


var cannons := []


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_max_range() -> float:
	
	if get_child_count() == 0:
		return 0.0
	
	var max_range : float = get_child(0).max_range
	
	for index in range(1, get_child_count()) :
		var canon = get_child(index)
		if canon.max_range > max_range:
			max_range = canon.max_range
	
	return max_range


func add_cannon(slot_id : int, cannon_info):
	var start_cannon_index := slot_id*2
	var max_index = get_children().size()
	for child_index in range(start_cannon_index, start_cannon_index+2):
		if child_index < max_index:
			var cannon := get_child(child_index)
			cannon.cannon_owner = owner
			cannon.damage = cannon_info.attributes.damage
			cannon.speed = cannon_info.attributes.range
			cannon.fire_rate = cannon_info.attributes.fire_rate
			cannons.append(cannon)
			print("Cannon added %d" % slot_id)


func remove_cannon(slot_id : int, cannon_info):
	var start_cannon_index := slot_id*2
	for child_index in range(start_cannon_index, start_cannon_index+2):
		var cannon := get_child(child_index)
		var index := find_cannon(cannon)
		if index != -1:
			cannons.remove( index )
			print("Cannon removed %d" % slot_id)
		else:
			push_error("Invalid index for cannon")


func is_fire_ready() -> bool:
	for cannon in cannons:
		if not cannon.fire_ready:
			return false
	return true


func fire(target_position : Vector3, target_velocity := Vector3.ZERO):
	for index in range(cannons.size()):
		var cannon = cannons[index]
		print("[%s] check fire ? " % cannon.name, cannon.fire_ready )
		if cannon.fire_ready and cannon.is_in_range(target_position):
			cannon.fire_delay = rand_range(0.0, 0.5)
			cannon.fire(target_position, target_velocity) 


func _on_Equipement_item_added(slot_id, item):
	
	var game_item := GameTable.get_item(item.item_id)
	
	if game_item and game_item.category == "Weapon" and game_item.type == "Cannon_1lb":
		
		add_cannon(slot_id, item)
		
		pass
	
	pass # Replace with function body.


func find_cannon(cannon) -> int:
	for index in range(cannons.size() ):
		if cannons[index] == cannon:
			return index
	return -1


func _on_Equipement_item_removed(slot_id, item):
	
	remove_cannon(slot_id, item)
	
	pass # Replace with function body.
