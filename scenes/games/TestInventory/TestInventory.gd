extends Spatial


var SHIP_WINDOW_SCENE = preload("res://scenes/ui/windows/ShipWindow/ShipWindow.tscn")

var INVENTORY_TRANSFERT_SCENE = preload("res://scenes/ui/windows/InventoryTransfert/InventoryTransfert.tscn")


onready var ship := $SwedishRoyalYachtAmadis

#onready var ship_inventory := $SwedishRoyalYachtAmadis/Inventory
onready var gui_canvas_layer := $CanvasLayer


var gui_ship_inventory
var ship_windows


# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	ship.inventory.add_item(1, {
			"item_id": 100001,
			"quantity": 8,
			"test": "toto"
		}
	)
	
	
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
			
			
			pass
		
		pass
	



func _on_InventoryButton_pressed():
	
	#if not gui_ship_inventory:
	if not ship_windows:
		"""
		gui_ship_inventory = MarginContainer.new()
		gui_ship_inventory.anchor_top = 0.5
		gui_ship_inventory.anchor_right = 0.5
		gui_ship_inventory.anchor_bottom = 0.5
		gui_ship_inventory.anchor_left = 0.5
		
		gui_ship_inventory.rect_min_size = Vector2(1000, 600)
		
		gui_ship_inventory.margin_left = -gui_ship_inventory.rect_min_size.x / 2
		gui_ship_inventory.margin_right = gui_ship_inventory.rect_min_size.x / 2
		gui_ship_inventory.margin_top = -gui_ship_inventory.rect_min_size.y / 2
		gui_ship_inventory.margin_bottom = -gui_ship_inventory.rect_min_size.y / 2
		"""
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
		"""
		gui_ship_inventory.queue_free()
		gui_ship_inventory = null
		"""
	
