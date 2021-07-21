extends Spatial


var SHIP_WINDOW_SCENE = preload("res://scenes/ui/windows/ShipWindow/ShipWindow.tscn")


onready var ship_inventory := $SwedishRoyalYachtAmadis/Inventory
onready var gui_canvas_layer := $CanvasLayer


var gui_ship_inventory


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_InventoryButton_pressed():
	
	if not gui_ship_inventory:
		
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
		
		var ship_windows = SHIP_WINDOW_SCENE.instance()
		
		gui_ship_inventory.add_child( ship_windows )
		
		gui_canvas_layer.add_child( gui_ship_inventory )
		
		ship_windows.ship_inventory.inventory = ship_inventory
		
		ship_windows.open()
	else:
		
		gui_ship_inventory.queue_free()
		gui_ship_inventory = null
		
	
