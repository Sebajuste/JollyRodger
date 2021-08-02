extends Spatial


var SHIP_WINDOW_SCENE = preload("res://scenes/ui/windows/ShipWindow/ShipWindow.tscn")
var INVENTORY_TRANSFERT_SCENE = preload("res://scenes/ui/windows/InventoryTransfert/InventoryTransfert.tscn")


onready var ship := $SwedishRoyalYachtAmadis
onready var gui_canvas_layer := $CanvasLayer
onready var crate = $Crate


var gui_ship_inventory
var ship_windows


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var item := GameTable.get_item(100001)
	
	ship.inventory.add_item(1, {
			"item_id": item.id,
			"quantity": 8,
			"attributes": item.attributes
		}
	)
	
	crate.get_node("Inventory").add_item(1, {
		"item_id": 101000,
		"quantity": 20
	})
	
	crate.get_node("Inventory").add_item(2, {
		"item_id": item.id,
		"quantity": 5,
		"attributes": item.attributes
	})
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	
	if event.is_action_pressed("ui_accept") and $SelectorHandler.has_select():
		
		var object : Spatial = $SelectorHandler.get_select()
		
		print("ui_accept ", object)
		
		if object.is_in_group("has_inventory") and object .global_transform.origin.distance_squared_to(ship.global_transform.origin) < 20*20:
			
			print("create transfert")
			
			var gui_transfert = INVENTORY_TRANSFERT_SCENE.instance()
			
			gui_canvas_layer.add_child(gui_transfert)
			
			gui_transfert.set_inventory_a(ship.inventory)
			gui_transfert.set_inventory_b(object.inventory)
			
			gui_transfert.show()
		


func _on_InventoryButton_pressed():
	
	#if not gui_ship_inventory:
	if not ship_windows:
		
		ship_windows = SHIP_WINDOW_SCENE.instance()
		
		#gui_ship_inventory.add_child( ship_windows )
		
		gui_canvas_layer.add_child( ship_windows )
		#gui_canvas_layer.add_child( gui_ship_inventory )
		
		ship_windows.ship_equipment.inventory = ship.equipement
		ship_windows.ship_inventory.inventory = ship.inventory
		
		ship_windows.show()
	else:
		ship_windows.queue_free()
		ship_windows = null
	
