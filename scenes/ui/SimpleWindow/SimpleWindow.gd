extends Control



export(NodePath) var faction_manager_path 


onready var faction_manager := get_node(faction_manager_path)

onready var gb_ship_count = $MarginContainer/VBoxContainer/Content/HBoxContainer/UnitedKingdomFaction/VBoxContainer/ShipCount
onready var pirate_ship_count = $MarginContainer/VBoxContainer/Content/HBoxContainer/PirateFaction/VBoxContainer/ShipCount



# Called when the node enters the scene tree for the first time.
func _ready():
	
	if faction_manager:
		_on_faction_data_updated(faction_manager.faction_data)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func open():
	
	$AnimationPlayer.play("fade_in")
	


func close():
	
	$AnimationPlayer.play("fade_out")
	


func _on_faction_data_updated(faction_data):
	
	if gb_ship_count:
		gb_ship_count.text = tr("label_ship_count") + (" : %d" % faction_data.gb_count)
	if pirate_ship_count:
		pirate_ship_count.text = tr("label_ship_count") + (" : %d" % faction_data.pirate_count)
	
	pass # Replace with function body.
