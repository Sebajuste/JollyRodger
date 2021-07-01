extends Node


var SLOOP_SCENE = preload("res://scenes/objects/ships/Sloop/Sloop.tscn")
var SELECT_HINT_SCENE = preload("res://scenes/miscs/SelectHint/SelectHint.tscn")

onready var world := $World
onready var camera := $World/CameraRig




var player

var target : AbstractShip
var select_hint



# Called when the node enters the scene tree for the first time.
func _ready():
	
	# If is not a dedicated server
	if not "--server" in OS.get_cmdline_args():
		player = SLOOP_SCENE.instance()
		player.set_network_master( Network.get_self_peer_id() )
		player.set_name( str(Network.get_self_peer_id()) )
		
		world.add_child(player)
		
		player.global_transform.origin = Vector3(
			rand_range(-100, 100),
			2.0,
			rand_range(-100, 100)
		)
		
		camera.target = player.get_node("CaptainPlace")
		
		$GUI/MarginContainer/BoatInfo.boat = player
		$GUI/MarginContainer2/BoatControl.boat = player
		
		$World/Ocean.update_shader()
		
		get_tree().connect("server_disconnected", self, "_server_disconnected")
		ObjectSelector.connect("object_selected", self, "_on_object_selected")
		
		print("Game ready")
	else:
		
		$GUI.queue_free()
		$AudioStreamPlayer.queue_free()
		
	
	
	$World/Ocean.set_network_master( 1 )
	
	print("Multiplayer scene ready")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	
#	pass


func _unhandled_input(event):
	
	if event is InputEventMouseButton:
		
		if event.button_index == BUTTON_LEFT:
			
			if select_hint:
				select_hint.queue_free()
				select_hint = null
			target = null
	
	
	if event.is_action_pressed("fire_order") and target:
		
		for canon in player.get_node("Cannons").get_children():
			
			var target_pos := target.global_transform.origin + Vector3.UP*3.0
			var target_velocity := target.linear_velocity
			
			if canon.fire_ready and canon.is_in_range(target_pos):
				
				canon.fire_delay = rand_range(0.0, 0.5)
				
				canon.fire(target_pos, target_velocity)
			


func _server_disconnected():
	print("server disconnected")
	Loading.load_scene("scenes/ui/LoginPanel/LoginPanel.tscn")
	
	pass


func _on_object_selected(object):
	
	if target != object and object != player:
		
		select_hint = SELECT_HINT_SCENE.instance()
		
		object.add_child(select_hint)
		select_hint.transform.origin.y = 15
		
		target = object
	
