tool
class_name HitBox
extends Area


signal hit


export(NodePath) var damage_stats_path

export var avoid_parent := false


onready var damage_stats : DamageStats = get_node(damage_stats_path)



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_damaged(damage_source : DamageSource):
	
	if avoid_parent and (owner.is_a_parent_of(damage_source) or owner.is_a_parent_of(damage_source.source) or owner == damage_source.source ):
		return
	
	print("[%s] damaged by %s" % [owner.name, damage_source.owner.name] )
	
	if Network.enabled:
		rpc("rpc_on_damage", damage_source.damage)
	else:
		rpc_on_damage(damage_source.damage)
	
	pass # Replace with function body.


master func rpc_on_damage(damage):
	var hit: = Hit.new(damage)
	if damage_stats and damage_stats.has_method("take_damage"):
		damage_stats.take_damage(hit, self)
	if Network.enabled:
		rpc("rpc_on_hit")
	rpc_on_hit()


puppet func rpc_on_hit():
	
	emit_signal("hit")
	
	"""
	if particles_scene:
		var particles = particles_scene.instance()
		particles.transform.origin = global_transform.origin
		get_tree().get_root().add_child(particles)
	"""
	
	pass


func _get_configuration_warning() -> String:
	
	return "Missing CombatStats node" if not damage_stats_path else ""
	
