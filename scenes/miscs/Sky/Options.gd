extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var _r := Configuration.connect("configuration_changed", self, "_on_configuration_changed")
	
	update_options()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_options():
	var god_rays = owner.get_node_or_null("GodRays")
	if god_rays:
		god_rays.visible = Configuration.Settings.Display.GodRays


func _on_configuration_changed(_config):
	
	update_options()
	
