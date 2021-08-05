extends Node


var item_rarity_distribution := {
	"Common": 60,
	"Uncommon": 27,
	"Rare": 9,
	"Epic": 3,
	"Legendary": 1
}


var items := []


func _ready():
	
	print("GameTable ready")
	
	var files := []
	var dir = Directory.new()
	dir.open("res://resources")
	dir.list_dir_begin()
	
	var file_it = dir.get_next()
	while file_it != "":
		if not file_it.begins_with("."):
			files.append(file_it)
		file_it = dir.get_next()
	dir.list_dir_end()
	
	for file_name in files:
		if file_name.ends_with(".csv"):
			load_csv("res://resources/%s" % file_name)


func load_csv(file_path):
	
	var file := File.new()
	
	file.open(file_path, File.READ)
	
	var headers : PoolStringArray
	
	var line := 0
	
	while not file.eof_reached():
		var csv_line := file.get_csv_line()
		
		if line == 0:
			headers = csv_line
		else:
			
			if csv_line.size() == headers.size():
				
				var item := {}
				
				for column_index in range(csv_line.size()):
					var column_name := headers[column_index].to_lower()
					item[column_name] = csv_line[column_index]
				
				if item.has("id") and item.id != "":
					var game_item := GameItem.new(item)
					items.append(game_item)
				
			else:
				push_warning("Invalid game item")
		
		line += 1
	
	file.close()
	


func get_item(id : int) -> GameItem:
	for index in range(items.size()):
		var item : GameItem = items[index]
		if item.id == id:
			return item
	push_warning("Cannot found game item [id=%d]" % id )
	return null
