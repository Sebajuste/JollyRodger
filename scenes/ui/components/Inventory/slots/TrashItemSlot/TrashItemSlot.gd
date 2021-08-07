class_name TrashItemSlot
extends AbstractItemSlot


export(PackedScene) var drop_container_scene : PackedScene

export var pop_distance := Vector2(1, 2)


var owner_ref := weakref(null)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func put(new_item : ItemHandler, amount : int = -1) -> bool:
	
	if drop_container_scene and drop_container_scene.can_instance():
		
		var owner_node = owner_ref.get_ref()
		if owner_node == null:
			return false
		
		var container := drop_container_scene.instance()
		
		var dir := Vector3(
			rand_range(-1, 1),
			0,
			rand_range(-1, 1)
		).normalized()
		
		var pos : Vector3 = owner_node.global_transform.origin + dir*pop_distance.x + dir*randf()*pop_distance.y
		container.transform.origin = pos
		
		container.set_network_master( owner_node.get_network_master() )
		
		Spawner.spawn(container)
		
		var slot_id : int = container.inventory.get_free_slot()
		
		container.inventory.add_item(slot_id, {
			"item_id": new_item.item.id,
			"item_rarity": new_item.rarity,
			"attributes": new_item.attributes,
			"quantity": max(amount, 1)
		})
		
		return true
	
	return false
