extends Node


var SHIP_SCENE = preload("res://scenes/objects/ships/SwedishRoyalYachtAmadis/SwedishRoyalYachtAmadis.tscn")
var SELECT_HINT_SCENE = preload("res://scenes/miscs/SelectHint/SelectHint.tscn")

onready var world := $World
onready var camera := $World/CameraRig




var player : AbstractShip
var player_ship_id := 0

var target : AbstractShip
var select_hint



# Called when the node enters the scene tree for the first time.
func _ready():
	
	# If is not a dedicated server
	if not "--server" in OS.get_cmdline_args():
		
		create_player()
		
		$World/Ocean.update_shader()
		
		get_tree().connect("server_disconnected", self, "_on_server_disconnected")
		Network.connect("disconnected", self, "_on_server_disconnected")
		
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


func create_player():
	
	player = SHIP_SCENE.instance()
	player.set_network_master( Network.get_self_peer_id() )
	player.set_name( "ship_%s_%d" % [str(Network.get_self_peer_id()), player_ship_id] )
	
	player_ship_id += 1
	
	player.global_transform.origin = Vector3(
		rand_range(-100, 100),
		2.0,
		rand_range(-100, 100)
	)
	
	world.add_child(player)
	
	camera.target = player.get_node("CaptainPlace")
	
	player.damage_stats.connect("health_depleted", self, "_on_ship_destroyed")
	
	$GUI/MarginContainer/BoatInfo.ship = player
	$GUI/MarginContainer2/BoatControl.boat = player
	



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
			


func _on_server_disconnected(a, b):
	print("server disconnected;  a: ", a, " b: ", b)
	Loading.load_scene("scenes/ui/LoginPanel/LoginPanel.tscn")
	
	pass


func _on_object_selected(object):
	
	if target != object and object != player:
		
		select_hint = SELECT_HINT_SCENE.instance()
		
		object.add_child(select_hint)
		select_hint.transform.origin.y = 15
		
		target = object


func _on_ship_destroyed():
	
	$GUI/SinkMenu.visible = true
	camera.target = null


func _on_RestartGameButton_pressed():
	$GUI/SinkMenu.visible = false
	create_player()
	
	pass # Replace with function body.
