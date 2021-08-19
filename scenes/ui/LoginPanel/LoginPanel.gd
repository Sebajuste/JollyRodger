extends Node



onready var login_input := $CanvasLayer/Control/TextureRect/MarginContainer/VBoxContainer/Login
onready var options_window := $CanvasLayer/Options

var password = null


# Called when the node enters the scene tree for the first time.
func _ready():
	
	login_input.text = "Player_%d" % randi()
	
	var _r
	_r = get_tree().connect("connected_to_server", self, "_connected_ok")
	_r = get_tree().connect("connection_failed", self, "_connected_fail")
	
	$CanvasLayer/Control/Version/Label.text = "Version " + str( Network.Settings.Version )
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ConnectButton_pressed():
	
	
	var login = login_input.text
	
	if login == "":
		return
	
	# TODO : authentication with password
	
	# TODO : join the game
	
	var arguments = {}
	
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	
	var host : String = Network.Settings.Host
	var port : int = Network.Settings.Port
	
	if arguments.has("host"):
		host = arguments.host
	
	
	
	var peer = NetworkedMultiplayerENet.new()
	var result = peer.create_client(host, port)
	
	if result != OK:
		return
	
	get_tree().set_network_peer(peer)
	
	
	
	
	pass # Replace with function body.


func _connected_ok():
	
	Network.enabled = true
	Network.is_server = false
	
	Network.set_property("game_version", Network.Settings.Version)
	Network.set_property("username", login_input.text)
	
	Loading.load_scene("scenes/games/Multiplayer/Multiplayer.tscn")
	


func _connected_fail():
	
	
	pass


func _on_ExitButton_pressed():
	
	get_tree().quit()
	
	pass # Replace with function body.


func _on_OptionsButton_pressed():
	
	options_window.popup_centered()
	
