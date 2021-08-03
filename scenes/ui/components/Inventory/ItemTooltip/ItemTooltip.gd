extends Popup


var STAT_SCENE = preload("res://scenes/ui/components/Inventory/ItemTooltip/ItemTooltipStat.tscn")


onready var name_label = $MarginContainer/VBoxContainer/Label
onready var description_label = $MarginContainer/VBoxContainer/Description

onready var stats_list = $MarginContainer/VBoxContainer/Statistics

var item : GameItem setget set_item


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update_item_info():
	
	name_label.text = item.name
	description_label.text = item.description
	
	
	for child in stats_list.get_children():
		child.queue_free()
	
	for stat_name in item.attributes:
		var stat_value = item.attributes[stat_name]
		
		#print("stat : ", stat_name, " -> ", stat_value)
		
		var stat_node = STAT_SCENE.instance()
		
		stat_node.get_node("Name").text = stat_name
		stat_node.get_node("Difference").text = str(stat_value)
		
		stats_list.add_child(stat_node)
		
		pass
	# STAT_SCENE
	
	pass


func set_item(value):
	item = value
	update_item_info()


func _on_visibility_changed():
	
	if visible:
		$AnimationPlayer.play("fade_in")
	
	pass # Replace with function body.
