extends Node


const CONFIG_FILE := "res://game_config.json"


const GAME_NAME := "JollyRoger"
const DEFAULT_GAME_PORT := 12345
const DEFAULT_MAX_PLAYER := 16

var upnp

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# To generate real random number
	randomize()
	
	
	var fs = File.new()
	
	if fs.file_exists(CONFIG_FILE):
		
		fs.open(CONFIG_FILE, File.READ)
		var content = fs.get_as_text()
		fs.close()
		
		var config : Dictionary = parse_json(content)
		
		Network.Settings.Host = config.get("server_host", "0.0.0.0")
		Network.Settings.Port = config.get("game_port", DEFAULT_GAME_PORT)
		Network.Settings.MaxPlayer = config.get("max_player", DEFAULT_MAX_PLAYER)
		
		
	else:
		Network.Settings.Host = "0.0.0.0"
		Network.Settings.Port = DEFAULT_GAME_PORT
		Network.Settings.MaxPlayer = DEFAULT_MAX_PLAYER
	
	Network.Settings.Version = ProjectSettings.get_setting("application/config/version")
	
	if "--server" in OS.get_cmdline_args():
		# Run your server startup code here...
		# Using this check, you can start a dedicated server by running
		# a Godot binary (headless or not) with the `--server` command-line argument.
		
		print("Dedicated Server startup")
		
		# Disable Audio
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)
		
		var game_port : int = Network.Settings.Port
		var game_max_players : int = Network.Settings.MaxPlayer
		
		var game_version : String = Network.Settings.Version
		
		var peer = NetworkedMultiplayerENet.new()
		var result = peer.create_server(game_port, game_max_players)
		
		if result != OK:
			print("Cannot start the server. Maybe, the game port is already used")
			get_tree().exit(-1)
			return
		
		get_tree().set_network_peer(peer)
		Network.enabled = true
		Network.is_server = true
		Network.set_property("game_version", game_version)
		
		print("Game Version : ", game_version)
		
		upnp = UPNP.new()
		upnp.discover()
		
		var external_address = upnp.query_external_address()
		
		upnp.add_port_mapping(game_port, game_port, GAME_NAME, "UDP", 3600)
		
		print("Server starded on %s:%d" % [external_address, game_port])
		
		get_tree().change_scene("res://scenes/games/Multiplayer/Multiplayer.tscn")
		
	else:
		
		#$Loading.load_resource("scenes/ui/LoginPanel/LoginPanel.tscn")
		
		Loading.load_scene("scenes/ui/LoginPanel/LoginPanel.tscn")
		
		pass
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
