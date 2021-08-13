extends Node


var SHIP_SLOOP_SCENE = preload("res://scenes/objects/ships/SwedishRoyalYachtAmadis/SwedishRoyalYachtAmadis.tscn")
var SHIP_FRIGATE_SCENE = preload("res://scenes/objects/ships/SwedishHemmemaStyrbjorn/SwedishHemmemaStyrbjorn.tscn")
var SELECT_HINT_SCENE = preload("res://scenes/miscs/SelectHint/SelectHint.tscn")
var SHIP_WINDOW_SCENE = preload("res://scenes/ui/windows/ShipWindow/ShipWindow.tscn")
var INVENTORY_TRANSFERT_SCENE = preload("res://scenes/ui/windows/InventoryTransfert/InventoryTransfert.tscn")


onready var world := $World
onready var camera := $World/CameraRig
onready var faction_manager := $FactionManager

onready var selector_handler := $SelectorHandler

onready var start_position_a := $World/Island01/SpawnPositionA
onready var start_position_b := $World/Island02/SpawnPositionB


onready var gui_control := $GUI/ControlContainer/BoatControl

var start_position := Vector3.ZERO

var admin_mode := false


var player : AbstractShip
var player_ship_id := 0

var player_ship_window_ref = weakref(null)


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# If is not a dedicated server
	if not "--server" in OS.get_cmdline_args():
		
		if not Network.enabled:
			Loading.load_scene("scenes/ui/LoginPanel/LoginPanel.tscn")
			return
		
		$World/Ocean.update_shader()
		
		get_tree().connect("server_disconnected", self, "_on_server_disconnected")
		Network.connect("kicked", self, "_on_server_kicked")
		
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
#	select_timer += delta
#	
#	pass


func _input(event):
	if event.is_action_pressed("ui_main_menu"):
		if not $GUI/GameMenu.visible:
			$GUI/GameMenu.open()
		else:
			$GUI/GameMenu.close()
	
	if event.is_action_pressed("use"):
		var target : Spatial = selector_handler.get_select()
		
		if target and target.is_in_group("has_inventory"):
			
			var gui_transfert = INVENTORY_TRANSFERT_SCENE.instance()
			$GUI.add_child(gui_transfert)
			gui_transfert.set_inventory_a(player.inventory)
			gui_transfert.set_inventory_b(target.inventory)
			gui_transfert.show()
			pass
		
		pass
	


func create_player():
	
	if admin_mode:
		player = SHIP_FRIGATE_SCENE.instance()
	else:
		player = SHIP_SLOOP_SCENE.instance()
	player.set_network_master( Network.get_self_peer_id() )
	player.set_name( "ship_%s_%d" % [str(Network.get_self_peer_id()), player_ship_id] )
	
	player_ship_id += 1
	
	player.transform.origin = start_position + Vector3(
		rand_range(-100, 100),
		2.0,
		rand_range(-100, 100)
	)
	
	world.add_child(player)
	
	player.look_at_from_position(player.global_transform.origin, Vector3.ZERO, Vector3.UP)
	
	camera.set_target( player.get_node("CaptainPlace") )
	
	player.damage_stats.connect("health_depleted", self, "_on_ship_destroyed")
	player.flag.faction = Network.get_self_property("faction")
	
	var cannon := GameTable.get_item(100001)
	for i in range(4):
		player.equipment.add_item_in_free_slot({
				"item_id": cannon.id,
				"quantity": 1,
				"attributes": cannon.attributes
			}
		)
	
	
	selector_handler.exclude_select.clear()
	selector_handler.exclude_select.append(player)
	
	gui_control.set_ship( player )
	$GUI/InGameMenu.visible = true


func return_login_screen():
	
	Loading.load_scene("scenes/ui/LoginPanel/LoginPanel.tscn")
	


func _on_server_disconnected():
	print("server disconnected")
	Loading.load_scene("scenes/ui/LoginPanel/LoginPanel.tscn")


func _on_server_kicked(cause):
	print("Kicked from server. Cause : ", cause)
	Loading.load_scene("scenes/ui/LoginPanel/LoginPanel.tscn")


func _on_ship_destroyed():
	
	$GUI/SinkMenu.open()
	$GUI/InGameMenu.visible = false
	
	camera.set_target( null )
	
	gui_control.set_ship( null )


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
	
	camera.set_target( null )
	
	gui_control.set_ship( null )
	
	if player:
		player.queue_free()
		player = null
	
	$GUI/FactionSelector.open()
	$GUI/GameMenu.close()
	


func _on_QuitGameButton_pressed():
	
	get_tree().quit()
	


func _on_AcceptButton_pressed():
	
	$GUI/GameMenu.close()
	


func _on_SpawnZone_spawn_object(object):
	
	object.faction = "Spain"
	
	object.control_mode = "AI"
	object.control_sm.get_node("Control/AI").follow_path($World/Path)
	
	var cannon := GameTable.get_item(100001)
	for i in range(4):
		object.equipment.add_item_in_free_slot({
				"item_id": cannon.id,
				"quantity": 1,
				"attributes": cannon.attributes
			}
		)
	
	var item_generator := GameItemGeneration.new()
	for i in range(10):
		object.inventory.add_item_in_free_slot( item_generator.generate_item() )
	
	pass # Replace with function body.


func _on_InGameMenu_help_clicked():
	
	$GUI/HelpContainer.visible = false if $GUI/HelpContainer.visible else true
	


func _on_InGameMenu_inventory_clicked():
	
	var player_ship_window = player_ship_window_ref.get_ref()
	
	#if not gui_ship_inventory:
	if not player_ship_window:
		
		player_ship_window = SHIP_WINDOW_SCENE.instance()
		
		$GUI.add_child( player_ship_window )
		
		player_ship_window.ship_equipment.inventory = player.equipment
		player_ship_window.ship_inventory.inventory = player.inventory
		
		player_ship_window.ship_ref = weakref(player)
		
		player_ship_window.show()
		
		player_ship_window_ref = weakref(player_ship_window)
	else:
		player_ship_window.queue_free()
		player_ship_window_ref = weakref(null)
	
