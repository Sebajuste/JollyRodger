extends Popup


const RARITY_COLORS:= {
	"Common": Color.white,
	"Uncommon": Color.aquamarine,
	"Rare": Color.cornflower,
	"Epic": Color.goldenrod,
	"Legendary": Color.orange
}


var STAT_SCENE = preload("res://scenes/ui/components/Inventory/ItemTooltip/ItemTooltipStat.tscn")


onready var name_label = $MarginContainer/VBoxContainer/Label
onready var description_label = $MarginContainer/VBoxContainer/Description

onready var stats_list = $MarginContainer/VBoxContainer/Statistics

var item : GameItem setget set_item
var rarity : String setget set_rarity
var attributes : Dictionary = {} setget set_attributes

# Called when the node enters the scene tree for the first time.
func _ready():
	
	update_item_info()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update_item_info():
	
	if item:
		name_label.text = item.name
		description_label.text = item.description
	
	if rarity:
		name_label.add_color_override("font_color", RARITY_COLORS[rarity])
	
	# Clear olf attributes info
	for child in stats_list.get_children():
		child.queue_free()
	
	# Add new attributes info
	for stat_name in attributes:
		var stat_value = attributes[stat_name]
		
		var stat_node = STAT_SCENE.instance()
		
		stat_node.get_node("Name").text = stat_name
		stat_node.get_node("Difference").text = str(stat_value)
		
		stats_list.add_child(stat_node)
		
	


func set_item(value):
	item = value
	update_item_info()


func set_rarity(value):
	if value:
		rarity = value
		update_item_info()


func set_attributes(value : Dictionary):
	attributes = value
	update_item_info()


func _on_visibility_changed():
	
	if visible:
		$AnimationPlayer.play("fade_in")
	
	pass # Replace with function body.
