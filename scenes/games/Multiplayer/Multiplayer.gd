extends Node


const START_POSITION_PATH := {
	"GB": "World/Island04NetProxy/SpawnPositionA",
	"Pirate": "World/Island05NetProxy/SpawnPositionB"
}


var SHIP_SLOOP_SCENE = preload("res://scenes/objects/ships/SwedishRoyalYachtAmadis/SwedishRoyalYachtAmadis.tscn")
var SHIP_FRIGATE_SCENE = preload("res://scenes/objects/ships/SwedishHemmemaStyrbjorn/SwedishHemmemaStyrbjorn.tscn")
var SELECT_HINT_SCENE = preload("res://scenes/miscs/SelectHint/SelectHint.tscn")
var SHIP_WINDOW_SCENE = preload("res://scenes/ui/windows/ShipWindow/ShipWindow.tscn")
var INVENTORY_TRANSFERT_SCENE = preload("res://scenes/ui/windows/InventoryTransfert/InventoryTransfert.tscn")

var FACTION_WINDOW_SCENE = preload("res://scenes/ui/windows/FactionSelector/FactionSelector.tscn")
var SINK_MENU_SCENE = preload("res://scenes/ui/windows/SinkWindow/SinkWindow.tscn")


onready var world := $World
onready var camera := $World/CameraRig
onready var faction_manager := $FactionManager

onready var selector_handler := $SelectorHandler

onready var start_position_a := $World/Island04NetProxy/SpawnPositionA
onready var start_position_b := $World/Island05NetProxy/SpawnPositionB

onready var gui_ingame_menu := $GUI/InGameMenu
onready var gui_control := $GUI/ControlContainer/BoatControl
onready var gui_cannons = $GUI/CannonsContainer/CannonStatus
onready var gui_weather_forecast = $GUI/ForecastContainer

onready var gui_game_menu := $GUI/GameMenu
onready var options_window := $GUI/OptionsWindow


var admin_mode := false
var player : AbstractShip
var player_ship_id := 0



# Called when the node enters the scene tree for the first time.
func _ready():
	
	var _r
	
	# If is not a dedicated server
	if not "--server" in OS.get_cmdline_args():
		
		if not Network.enabled:
			Loading.load_scene("scenes/ui/LoginPanel/LoginPanel.tscn")
			return
		
		$World/Ocean.update_shader()
		
		_r = get_tree().connect("server_disconnected", self, "_on_server_disconnected")
		_r = Network.connect("kicked", self, "_on_server_kicked")
		
		
		print("Game ready")
	else:
		
		_r = get_tree().connect("network_peer_connected", self, "_on_player_connected")
		
		# $AudioStreamPlayer.queue_free()
		pass
	
	create_faction_window()
	
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
		if not gui_game_menu.visible:
			gui_game_menu.popup_centered()
		else:
			gui_game_menu.hide()
		get_tree().set_input_as_handled()
	
	if event.is_action_pressed("show_forecast"):
		if not gui_weather_forecast.visible:
			gui_weather_forecast.visible = true
		else:
			gui_weather_forecast.visible = false
		get_tree().set_input_as_handled()
	


func _unhandled_input(event):
	
	if event.is_action_pressed("use"):
		var target : Spatial = selector_handler.get_select()
		
		if target and target.is_in_group("has_inventory"):
			
			var gui_transfert = INVENTORY_TRANSFERT_SCENE.instance()
			$GUI.add_child(gui_transfert)
			gui_transfert.set_inventory_a(player.inventory)
			gui_transfert.set_inventory_b(target.inventory)
			
			gui_transfert.set_name_a(player.name)
			gui_transfert.set_name_b(target.name)
			
			gui_transfert.popup_centered()
			
			get_tree().set_input_as_handled()
		


func read_save_file() -> Dictionary:
	
	var username : String = Network.get_self_property("username").to_lower()
	var filename : String = "%s.savegame" % username
	
	var fs := File.new()
	
	if fs.file_exists(filename):
		var r := fs.open(filename, File.READ)
		if r != OK:
			return {}
		var content = fs.get_as_text()
		fs.close()
		
		var save = parse_json(content)
		
		if typeof(save) != TYPE_DICTIONARY:
			return {}
		
		var save_seed : String = save.save_seed
		var save_hash : String = save.save_hash
		var payload : Dictionary = save.payload
		
		var ctx := HashingContext.new()
		var _r
		_r = ctx.start(HashingContext.HASH_SHA256)
		
		_r = ctx.update(save_seed.to_utf8() + Network.Settings.SecurityKey.to_utf8())
		_r = ctx.update(to_json(payload).to_utf8())
		var res := ctx.finish()
		
		if save_hash != res.hex_encode():
			_r = fs.open(filename, File.WRITE)
			fs.store_line("")
			fs.close()
			return {}
		
		return payload
	
	return {}


func write_save_file(savegame : Dictionary):
	
	var username : String = Network.get_self_property("username").to_lower()
	var filename : String = "%s.savegame" % username
	
	randomize()
	
	var save_seed := str(randi())
	
	var ctx := HashingContext.new()
	var r := ctx.start(HashingContext.HASH_SHA256)
	
	r = ctx.update(save_seed.to_utf8() + Network.Settings.SecurityKey.to_utf8())
	r = ctx.update(to_json(savegame).to_utf8())
	var res := ctx.finish()
	
	var save_hash := res.hex_encode()
	
	var save := {
		"save_seed": save_seed,
		"save_hash": save_hash,
		"payload": savegame
	}
	
	var dir := Directory.new()
	r = dir.remove(filename)
	
	var fs := File.new()
	r = fs.open(filename, File.WRITE)
	if r == OK:
		fs.store_line( to_json(save) )
		fs.close()
		print("saved : ", savegame)
	else:
		push_error("Cannot write savegame")
	


func create_faction_window():
	var gui_faction_selector : Popup = FACTION_WINDOW_SCENE.instance()
	gui_faction_selector.faction_manager = faction_manager
	$GUI.add_child(gui_faction_selector)
	var _r
	_r = gui_faction_selector.connect("gb_faction_joined", self, "_on_JoinUnitedKingdom_pressed", [gui_faction_selector])
	_r = gui_faction_selector.connect("pirate_faction_joined", self, "_on_JoinPirate_pressed", [gui_faction_selector])
	_r = gui_faction_selector.connect("exited", self, "_on_QuitGameButton_pressed")
	gui_faction_selector.popup_centered()
	


func create_player():
	
	var faction : String = Network.get_self_property("faction")
	
	var savegame := read_save_file()
	
	var ship_save := {}
	var ship_loaded := false
	
	if savegame.has(faction):
		print("faction found in save")
		ship_save = savegame[faction]
		
		if not ship_save.has("equipment") or ship_save.equipment.empty():
			ship_loaded = false
		else:
			ship_loaded = true
	
	if admin_mode:
		player = SHIP_FRIGATE_SCENE.instance()
	else:
		player = SHIP_SLOOP_SCENE.instance()
	
	
	var start_position := Vector3.ZERO
	
	if START_POSITION_PATH.has(faction):
		var start_path : String = START_POSITION_PATH[faction]
		var start : Spatial = get_node(start_path)
		start_position = start.global_transform.origin
	
	
	player.set_network_master( Network.get_self_peer_id() )
	player.set_name( "ship_%s_%d" % [str(Network.get_self_peer_id()), player_ship_id] )
	player_ship_id += 1
	
	player.label = Network.get_self_property("username")
	player.faction = faction
	
	if ship_save.has("health"):
		player.get_node("DamageStats").health = ship_save.health
	
	if ship_save.has("position"):
		player.transform.origin.x = ship_save.position.x
		player.transform.origin.y = ship_save.position.y
		player.transform.origin.z = ship_save.position.z
	else:
		player.transform.origin = start_position + Vector3(
			rand_range(-30, 30),
			2.0,
			rand_range(-30, 30)
		)
	
	world.add_child(player)
	
	player.username_label.text = player.label
	
	if ship_save.has("rotation"):
		var quat := Quat(ship_save.rotation.x, ship_save.rotation.y, ship_save.rotation.z, ship_save.rotation.w)
		player.transform.basis = Transform(quat).basis
		pass
	else:
		player.look_at_from_position(player.global_transform.origin, Vector3.ZERO, Vector3.UP)
	
	camera.set_target( player.get_node("CaptainPlace") )
	
	var _r = player.damage_stats.connect("health_depleted", self, "_on_ship_destroyed")
	
	gui_control.set_ship( player )
	gui_cannons.set_ship( player )
	
	gui_control.visible = true
	gui_cannons.visible = true
	gui_ingame_menu.visible = true
	
	player.selectable = false
	selector_handler.exclude_select.clear()
	selector_handler.exclude_select.append(player)
	
	if ship_loaded:
		print("load inventory")
		for key in ship_save.equipment:
			player.equipment.add_item(key.to_int(), ship_save.equipment[key])
		for key in ship_save.inventory:
			player.inventory.items[key.to_int()] = ship_save.inventory[key]
	else: # Add default equipment
		print("add default inventory")
		var cannon := GameTable.get_item(100001)
		for _i in range(4):
			player.equipment.add_item_in_free_slot({
					"item_id": cannon.id,
					"item_rariry": "Common",
					"quantity": 1,
					"attributes": cannon.attributes
				}
			)
	
	_r = player.inventory.connect("inventory_updated", self, "on_inventory_changed")
	_r = player.equipment.connect("inventory_updated", self, "on_inventory_changed")
	
	#
	# Save
	#
	ship_save = create_json_ship(player)
	
	savegame[faction] = ship_save
	
	print("Save after create ship")
	write_save_file(savegame)
	


func save_current_ship():
	
	var savegame := read_save_file()
	
	var faction : String = Network.get_self_property("faction")
	
	var ship_save = create_json_ship(player)
	
	savegame[faction] = ship_save
	
	print("Save current ship")
	write_save_file(savegame)
	


func create_json_ship(ship : AbstractShip) -> Dictionary:
	var rot := ship.global_transform.basis.get_rotation_quat()
	var pos := ship.global_transform.origin
	return {
		"equipment": ship.equipment.items,
		"inventory": ship.inventory.items,
		"health": ship.damage_stats.health,
		"rotation": {
			"x": rot.x,
			"y": rot.y,
			"z": rot.z,
			"w": rot.w
		},
		"position": {
			"x": pos.x,
			"y": pos.y,
			"z": pos.z
		}
	}


func return_login_screen():
	save_current_ship()
	Network.close_connection()
	
	Loading.load_scene("scenes/ui/LoginPanel/LoginPanel.tscn")
	


func _on_server_disconnected():
	save_current_ship()
	print("server disconnected")
	Loading.load_scene("scenes/ui/LoginPanel/LoginPanel.tscn")


func _on_server_kicked(cause):
	save_current_ship()
	print("Kicked from server. Cause : ", cause)
	Loading.load_scene("scenes/ui/LoginPanel/LoginPanel.tscn")


func _on_player_connected():
	
	var peer_count := Network.get_count_peers()
	
	var count_ship_spawn := int(max(peer_count / 2.0, 1.0))
	
	$World/SpawnZone.count_object = count_ship_spawn
	$World/SpawnZone2.count_object = count_ship_spawn
	
	pass


func destroy_ship():
	
	camera.set_target( null )
	
	gui_control.set_ship( null )
	gui_cannons.set_ship( null )
	
	gui_control.visible = false
	gui_cannons.visible = false
	gui_ingame_menu.visible = false
	
	# Remove ship destroyed
	var savegame := read_save_file()
	var faction : String = Network.get_self_property("faction")
	var _r := savegame.erase(faction)
	print("save after destroy -> ")
	write_save_file(savegame)
	player.destroy()
	


func _on_ship_destroyed():
	
	# $GUI/SinkMenu.open()
	
	var gui_sink = SINK_MENU_SCENE.instance()
	$GUI.add_child(gui_sink)
	
	gui_sink.connect("confirmed", self, "create_player")
	
	gui_sink.popup_centered()
	
	destroy_ship()





"""
func _on_RestartGameButton_pressed():
	$GUI/SinkMenu.close()
	create_player()
"""

func _on_JoinUnitedKingdom_pressed(window):
	window.queue_free()
	#$GUI/FactionSelector.close()
	#var start_position = start_position_a.global_transform.origin
	Network.set_property("faction", "GB")
	create_player()


func _on_JoinPirate_pressed(window):
	window.queue_free()
	#$GUI/FactionSelector.close()
	#var start_position = start_position_b.global_transform.origin
	Network.set_property("faction", "Pirate")
	create_player()


func _on_ChangeFactionButton_pressed():
	
	save_current_ship()
	
	camera.set_target( null )
	
	gui_control.visible = false
	gui_cannons.visible = false
	gui_ingame_menu.visible = false
	
	gui_control.set_ship( null )
	gui_cannons.set_ship( null )
	
	if player:
		player.queue_free()
		player = null
	
	create_faction_window()
	
	gui_game_menu.hide()
	


func _on_OptionsButton_pressed():
	
	options_window.popup_centered()
	


func on_inventory_changed(_items):
	if player.is_alive():
		save_current_ship()



func _on_QuitGameButton_pressed():
	save_current_ship()
	get_tree().quit()
	

"""
func _on_AcceptButton_pressed():
	
	gui_game_menu.close()
	
"""

func _on_SpawnZone_object_created(object):
	
	object.faction = "Spain"
	object.label = "label_ship_spain"
	
	pass # Replace with function body.


func _on_SpawnZone_spawn_object(object):
	
	object.label = "label_ship_spain"
	
	object.control_mode = "AI"
	object.control_sm.get_node("Control/AI").follow_path($World/Path, true)
	
	var cannon := GameTable.get_item(100001)
	for _i in range(4):
		object.equipment.add_item_in_free_slot({
				"item_id": cannon.id,
				"quantity": 1,
				"attributes": cannon.attributes
			}
		)
	
	var item_generator := GameItemGeneration.new()
	for _i in range(10):
		object.inventory.add_item_in_free_slot( item_generator.generate_item() )
	
	pass # Replace with function body.


func _on_InGameMenu_help_clicked():
	
	$GUI/HelpContainer.visible = false if $GUI/HelpContainer.visible else true
	


func _on_InGameMenu_inventory_clicked():
	
	var player_ship_window = SHIP_WINDOW_SCENE.instance()
	
	$GUI.add_child( player_ship_window )
	
	player_ship_window.ship_equipment.set_inventory( player.equipment )
	player_ship_window.ship_inventory.set_inventory( player.inventory )
	
	player_ship_window.ship_ref = weakref(player)
	
	player_ship_window.popup_centered()
	



func _on_GameMenu_ship_scuttled():
	
	print("_on_GameMenu_ship_scuttled")
	
	gui_game_menu.hide()
	
	destroy_ship()
	
	create_player()
	
	pass # Replace with function body.
