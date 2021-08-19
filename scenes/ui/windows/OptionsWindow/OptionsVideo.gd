extends VBoxContainer

onready var resolution_select = $HBoxContainer/ResolutionList

onready var fullscreen_checkbox = $HBoxContainer2/Fullscreen
onready var vsync_checkbox = $HBoxContainer3/Vsync
onready var antialiasing_checkbox = $HBoxContainer4/Antialiasing

onready var trees_details_select = $HBoxContainer5/TreesDetailsList


const TREES_DETAILS := {
	0: "ultra",
	1: "high",
	2: "medium",
	3: "low",
}


var display = {"h" : 0,"w":0}
var fullscreen
var antialiasing = true
var vsync = true

var trees_detail_level : String

func reload():
	
	display.h = Configuration.Settings.Display.HEIGHT
	display.w = Configuration.Settings.Display.WIDTH
	fullscreen = Configuration.Settings.Display.FullScreen
	vsync = Configuration.Settings.Display.Vsync
	antialiasing = Configuration.Settings.Display.Antialiasing
	
	trees_detail_level = Configuration.Settings.Display.Trees
	
	for index in resolution_select.get_item_count():
		var text = resolution_select.get_item_text(index)
		var res = text.split("x")
		
		if res[1] == String(display.h) && res[0] == String(display.w):
			resolution_select.select(index)
	
	fullscreen_checkbox.pressed = fullscreen
	vsync_checkbox.pressed = vsync
	antialiasing_checkbox.pressed = antialiasing
	

func apply():
	
	Configuration.Settings.Display.HEIGHT = display.h
	Configuration.Settings.Display.WIDTH = display.w
	Configuration.Settings.Display.FullScreen = fullscreen
	Configuration.Settings.Display.Vsync = vsync
	Configuration.Settings.Display.Antialiasing = antialiasing
	
	Configuration.Settings.Display.Trees = trees_detail_level
	
	Configuration.apply_settings()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#resolution_select.add_item("640x480")
	#resolution_select.add_item("800x600")
	resolution_select.add_item("1280x720")
	resolution_select.add_item("1600x900")
	resolution_select.add_item("1920x1080")
	
	reload()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_ResolutionList_item_selected(ID):
	
	var res = resolution_select.get_item_text(ID).split("x")
	display.w = res[0]
	display.h = res[1]
	apply()


func _on_Fullscreen_toggled(button_pressed):
	
	fullscreen = button_pressed
	apply()


func _on_Vsync_toggled(button_pressed):
	
	vsync = button_pressed
	apply()


func _on_Antialiasing_toggled(button_pressed):
	
	antialiasing = button_pressed
	apply()


func _on_TreesDetailsList_item_selected(index):
	trees_detail_level = TREES_DETAILS[index]
	apply()
