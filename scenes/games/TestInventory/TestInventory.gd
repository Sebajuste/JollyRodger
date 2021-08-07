extends Spatial


var SHIP_WINDOW_SCENE = preload("res://scenes/ui/windows/ShipWindow/ShipWindow.tscn")
var INVENTORY_TRANSFERT_SCENE = preload("res://scenes/ui/windows/InventoryTransfert/InventoryTransfert.tscn")


onready var ship := $SwedishRoyalYachtAmadis
onready var ship_ai = $ShipAI
onready var gui_canvas_layer := $CanvasLayer
onready var crate = $Crate


var gui_ship_inventory
var ship_windows


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var coins := GameTable.get_item(1)
	var cannon := GameTable.get_item(100001)
	var rudder := GameTable.get_item(100100)
	var sail := GameTable.get_item(100200)
	
	
	#Player inventory
	ship.inventory.add_item_in_free_slot({
			"item_id": cannon.id,
			"quantity": 8,
			"attributes": cannon.attributes
		}
	)
	
	ship.inventory.add_item_in_free_slot({
			"item_id": rudder.id,
			"quantity": 1,
			"attributes": rudder.attributes
		}
	)
	
	ship.inventory.add_item_in_free_slot({
			"item_id": sail.id,
			"quantity": 2,
			"attributes": sail.attributes
		}
	)
	
	ship.inventory.add_item_in_free_slot({
			"item_id": coins.id,
			"quantity": 1000
		}
	)
	
	#  Create Inventory
	crate.get_node("Inventory").add_item_in_free_slot({
		"item_id": 101000,
		"quantity": 20
	})
	
	crate.get_node("Inventory").add_item_in_free_slot({
		"item_id": cannon.id,
		"quantity": 5,
		"attributes": cannon.attributes
	})
	
	#AI Inventory
	
	var item_generator := GameItemGeneration.new()
	
	for i in range(10):
		
		ship_ai.inventory.add_item_in_free_slot( item_generator.generate_item() )
		
		ship.inventory.add_item_in_free_slot( item_generator.generate_item() )
		
	
	ship_ai.inventory.add_item_in_free_slot( {
		"item_id": 101000,
		"quantity": 20
	})
	
	crate._on_SinkTimer_timeout()
	
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
		
		gui_canvas_layer.add_child( ship_windows )
		
		ship_windows.ship_equipment.inventory = ship.equipment
		ship_windows.ship_inventory.inventory = ship.inventory
		
		ship_windows.ship_ref = weakref(ship)
		
		ship_windows.show()
	else:
		ship_windows.queue_free()
		ship_windows = null
	


func _on_DropAll_pressed():
	
	ship._drop()
	
	pass # Replace with function body.
