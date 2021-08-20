extends Spatial


signal object_created(object)
signal spawn_object(object)
signal all_despawned()


export(PackedScene) var spawn_object
export var count_object := 1 setget set_count_object
export var area := Vector3(1, 0, 1)
export var respawn_timer := 60
export var autostart := true
export var autoreload := false setget set_autoreload


onready var timer := $Timer


var object_spawned := []
var spawn_ready := true
var startup := true


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_network_master(1)
	
	if Network.enabled and not is_network_master():
		set_process(false)
		return
	
	timer.wait_time = respawn_timer
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if startup:
		startup = false
		spawn()
	set_process(false)


func spawn():
	
	if Network.enabled and not is_network_master():
		set_process(false)
		return
	
	if autoreload and not spawn_ready:
		return
	
	for _index in range(count_object):
		
		var position := global_transform.origin + Vector3(
			rand_range(-area.x, area.x),
			rand_range(-area.y, area.y),
			rand_range(-area.z, area.z)
		)
		
		var peer_id := Network.get_self_peer_id()
		var instance = spawn_object.instance()
		instance.name = "%s_%d_%d" % [instance.name, peer_id, randi()]
		instance.transform.origin = position
		instance.set_network_master( self.get_network_master() )
		
		emit_signal("object_created", instance)
		
		Spawner.spawn(instance)
		
		emit_signal("spawn_object", instance)
		
		instance.connect("tree_exited", self, "_on_instance_tree_exited_or_destroyed", [instance])
		instance.connect("destroyed", self, "_on_instance_tree_exited_or_destroyed", [instance])
		
		object_spawned.append(weakref(instance))
	
	spawn_ready = false
	
	pass


func set_count_object(value):
	
	count_object = int(max(value, 1))
	


func set_autoreload(value):
	autoreload = value
	


func _on_instance_tree_exited_or_destroyed(instance):
	for instance_ref in object_spawned:
		if instance_ref.get_ref() == instance:
			object_spawned.erase(instance_ref)
			break
	instance.disconnect("tree_exited", self, "_on_instance_tree_exited_or_destroyed")
	instance.disconnect("destroyed", self, "_on_instance_tree_exited_or_destroyed")
	if object_spawned.empty():
		if autoreload:
			if timer.is_inside_tree():
				timer.start()
		emit_signal("all_despawned")


func _on_Timer_timeout():
	
	spawn_ready = true
	spawn()
