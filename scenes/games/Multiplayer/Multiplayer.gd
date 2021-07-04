extends Node


var SHIP_SLOOP_SCENE = preload("res://scenes/objects/ships/SwedishRoyalYachtAmadis/SwedishRoyalYachtAmadis.tscn")
var SHIP_FRIGATE_SCENE = preload("res://scenes/objects/ships/SwedishHemmemaStyrbjorn/SwedishHemmemaStyrbjorn.tscn")
var SELECT_HINT_SCENE = preload("res://scenes/miscs/SelectHint/SelectHint.tscn")

onready var world := $World
onready var camera := $World/CameraRig
onready var faction_manager := $FactionManager


onready var start_position_a := $World/Island01/SpawnPositionA
onready var start_position_b := $World/Island02/SpawnPositionB


var start_position := Vector3.ZERO

var admin_mode := false


var player : AbstractShip
var player_ship_id := 0

var target : AbstractShip
var select_hint



# Called when the node enters the scene tree for the first time.
func _ready():
	
	# If is not a dedicated server
	if not "--server" in OS.get_cmdline_args():
		
		$World/Ocean.update_shader()
		
		get_tree().connect("server_disconnected", self, "_on_server_disconnected")
		Network.connect("disconnected", self, "_on_server_disconnected")
		
		ObjectSelector.connect("object_selected", self, "_on_object_selected")
		
		$GUI/FactionSelector.open()
		
		print("Game ready")
	else:
		
		#$GUI.queue_free()
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
	
	if event.is_action_pressed("ui_main_menu"):
		
		if not $GUI/GameMenu.visible:
			$GUI/GameMenu.open()
		else:
			$GUI/GameMenu.close()
	
	


func create_player():
	
	if admin_mode:
		player = SHIP_FRIGATE_SCENE.instance()
	else:
		player = SHIP_SLOOP_SCENE.instance()
	player.set_network_master( Network.get_self_peer_id() )
	player.set_name( "ship_%s_%d" % [str(Network.get_self_peer_id()), player_ship_id] )
	
	player_ship_id += 1
	
	player.global_transform.origin = start_position + Vector3(
		rand_range(-100, 100),
		2.0,
		rand_range(-100, 100)
	)
	
	world.add_child(player)
	
	#player.look_at_from_position(player.global_transform.origin, Vector3.ZERO, Vector3.UP)
	
	camera.target = player.get_node("CaptainPlace")
	
	player.damage_stats.connect("health_depleted", self, "_on_ship_destroyed")
	player.flag.type = Network.get_self_property("faction")
	
	$GUI/MarginContainer/BoatInfo.ship = player
	$GUI/MarginContainer2/BoatControl.boat = player
	


func return_login_screen():
	
	Loading.load_scene("scenes/ui/LoginPanel/LoginPanel.tscn")
	


func _on_server_disconnected(a, b):
	print("server disconnected;  a: ", a, " b: ", b)
	Loading.load_scene("scenes/ui/LoginPanel/LoginPanel.tscn")


func _on_object_selected(object):
	
	if target != object and object != player:
		
		select_hint = SELECT_HINT_SCENE.instance()
		
		object.add_child(select_hint)
		select_hint.offset.y = 30
		
		target = object


func _on_ship_destroyed():
	
	$GUI/SinkMenu.open()
	camera.target = null
	$GUI/MarginContainer/BoatInfo.ship = null
	$GUI/MarginContainer2/BoatControl.boat = null


func _on_RestartGameButton_pressed():
	$GUI/SinkMenu.close()
	create_player()


func _on_JoinUnitedKingdom_pressed():
	$GUI/FactionSelector.close()
	start_position = start_position_a.global_transform.origin
	Network.set_property("faction", "GB")
	create_player()


func _on_JoinPirate_pressed():
	$GUI/FactionSelector.close()
	start_position = start_position_b.global_transform.origin
	Network.set_property("faction", "Pirate")
	create_player()


func _on_ChangeFactionButton_pressed():
	
	camera.target = null
	
	$GUI/MarginContainer/BoatInfo.ship = null
	$GUI/MarginContainer2/BoatControl.boat = null
	
	if player:
		player.queue_free()
		player = null
	
	$GUI/FactionSelector.open()
	$GUI/GameMenu.close()
	


func _on_QuitGameButton_pressed():
	
	get_tree().quit()
	


func _on_AcceptButton_pressed():
	
	$GUI/GameMenu.close()
	
