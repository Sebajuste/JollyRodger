extends Popup


signal gb_faction_joined()
signal pirate_faction_joined()
signal exited()


export(NodePath) var faction_manager_path 


onready var faction_manager : FactionManager
onready var gb_ship_count = $MarginContainer/VBoxContainer/Content/UnitedKingdomFaction/VBoxContainer/ShipCount
onready var pirate_ship_count = $MarginContainer/VBoxContainer/Content/PirateFaction/VBoxContainer/ShipCount



# Called when the node enters the scene tree for the first time.
func _ready():
	
	if faction_manager_path:
		faction_manager = get_node(faction_manager_path)
	
	if faction_manager:
		var _r := faction_manager.connect("faction_data_updated", self, "_on_faction_data_updated")
		_on_faction_data_updated(faction_manager.faction_data)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_faction_data_updated(faction_data):
	if gb_ship_count:
		gb_ship_count.text = tr("label_ship_count") + (" : %d" % faction_data.gb_count)
	if pirate_ship_count:
		pirate_ship_count.text = tr("label_ship_count") + (" : %d" % faction_data.pirate_count)


func _on_FactionSelector_visibility_changed():
	
	if visible:
		
		Network.set_property("faction", "None")
		
	


func _on_JoinGBFactionButton_pressed():
	
	emit_signal("gb_faction_joined")
	


func _on_JoinPirateFactionButton_pressed():
	
	emit_signal("pirate_faction_joined")
	


func _on_QuitButton_pressed():
	
	emit_signal("exited")
	
