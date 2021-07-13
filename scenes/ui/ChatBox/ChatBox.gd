extends Control


export var draggable := false



var channels := [
	{"name": "Local", "color": "#ffffff"},
	{"name": "Faction", "color": "#34c5f5"},
	{"name": "Global", "color": "#f1c234"}
]


onready var channel_selector := $VBoxContainer/HBoxContainer/ChannelSelector
onready var input_field := $VBoxContainer/HBoxContainer/MessageLineEdit
onready var chat_log := $VBoxContainer/RichTextLabel


var drag_position = null


# Called when the node enters the scene tree for the first time.
func _ready():
	
	channel_selector.select_channel("Global")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	
	if event is InputEventKey:
		
		if event.pressed and event.scancode == KEY_ESCAPE:
			
			input_field.release_focus()
			
		
		if event.pressed and event.scancode == KEY_ENTER:
			
			if input_field.text.length() > 0 and input_field.has_focus():
				_on_MessageLineEdit_text_entered(input_field.text)
			elif input_field.has_focus():
				input_field.release_focus()
			else:
				input_field.grab_focus()
			
		
		if event.pressed and event.scancode == KEY_TAB:
			
			# TODO : switch tab
			
			pass


func get_channel(name : String) -> Dictionary:
	for channel in channels:
		if channel.name == name:
			return channel
	return {}


remotesync func rpc_add_message(username, text, channel_name := "Local"):
	
	print("rpc_add_message")
	
	var channel := get_channel(channel_name)
	
	if not channel.has("color"):
		return
	
	chat_log.bbcode_text += "\n"
	chat_log.bbcode_text += "[color=%s]" % channel.color
	chat_log.bbcode_text += "[%s]: " % username
	chat_log.bbcode_text += text
	chat_log.bbcode_text += "[/color]"
	


func change_channel(channel_name):
	var channel := get_channel(channel_name)
	if channel.has("color"):
		channel_selector.set("custom_colors/font_color", Color(channel.color) )


func _get_peer_ids(channel_name) -> Array:
	
	var ids := []
	
	match channel_name:
		"Global":
			return Network.player_info.keys()
		"Faction":
			var faction = Network.get_self_property("faction")
			var peer_ids : Array = Network.player_info.keys()
			print("peer_ids : ", peer_ids)
			for index in range(peer_ids.size()):
				var peer_id : int = peer_ids[index]
				if Network.has_property(peer_id, "faction"):
					var peer_faction : String = Network.get_property(peer_id, "faction")
					if peer_faction == faction:
						ids.append(peer_id)
		"Local":
			pass
	
	return ids


func _on_MessageLineEdit_text_entered(text):
	
	print("text_entered: ", text)
	
	input_field.text = ""
	input_field.release_focus()
	
	var username : String = Network.get_self_property("username") if Network.enabled else "Player"
	
	var channel_name : String = channel_selector.channel_selected
	
	if get_tree().has_network_peer():
		var peer_ids := _get_peer_ids(channel_name)
		for index in range(peer_ids.size()):
			var peer_id = peer_ids[index]
			rpc_id(peer_id, "rpc_add_message", username, text, channel_name)
	else:
		rpc_add_message(username, text, channel_name)
	


func _on_SendButton_pressed():
	
	_on_MessageLineEdit_text_entered(input_field.text)
	
	pass # Replace with function body.


func _on_ChatBox_gui_input(event):
	
	if event is InputEventMouseButton:
		
		if event.pressed:
			print("start drag")
			drag_position = get_global_mouse_position() - rect_global_position
		else:
			print("end drag")
			drag_position = null
	
	if event is InputEventMouseMotion and drag_position:
		
		rect_global_position = get_global_mouse_position() - drag_position
		
	
	pass # Replace with function body.
