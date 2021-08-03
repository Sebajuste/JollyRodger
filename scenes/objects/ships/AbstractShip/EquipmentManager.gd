extends Node


var cannons
var base_sail_force := 0.0
var sail_force_bonus := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	cannons = owner.get_node("Cannons")
	base_sail_force = owner.sail_force
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update_stats():
	
	owner.sail_force = sail_force_bonus
	
	pass


func _on_Equipment_item_added(slot_id, item):
	
	var game_item := GameTable.get_item(item.item_id)
	
	if game_item and game_item.category == "Weapon" and game_item.type == "Cannon_1lb":
		cannons.add_cannon(slot_id, item)
	
	if game_item and game_item.category == "Sail":
		sail_force_bonus = max(0, sail_force_bonus + item.attributes.speed)
	
	update_stats()
	


func _on_Equipment_item_removed(slot_id, item):
	
	var game_item := GameTable.get_item(item.item_id)
	
	if game_item and game_item.category == "Weapon" and game_item.type == "Cannon_1lb":
		cannons.remove_cannon(slot_id, item)
	
	if game_item and game_item.category == "Sail":
		sail_force_bonus = max(0, sail_force_bonus - item.attributes.speed)
	
	update_stats()
	


func _on_Equipment_item_quantity_changed(slot_id, item, old_quantity):
	
	update_stats()
	
