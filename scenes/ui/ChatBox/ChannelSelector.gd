extends MenuButton


signal channel_changed(channel_name)

var channel_selected 

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var _r := get_popup().connect("index_pressed", self, "_on_index_pressed")
	
	channel_selected = get_popup().get_item_text(0)
	self.text = channel_selected
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func select_channel(channel_name : String):
	for index in range(get_popup().get_item_count()):
		var name := get_popup().get_item_text(index)
		if name == channel_name:
			_on_index_pressed(index)
			return



func _on_index_pressed(index : int):
	channel_selected = get_popup().get_item_text(index)
	self.text = channel_selected
	emit_signal("channel_changed", channel_selected)
