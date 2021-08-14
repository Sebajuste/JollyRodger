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
	
	var files := []
	var dir = Directory.new()
	var r = dir.open("res://resources")
	
	if r != OK:
		push_error("Cannot open res://resources directory")
		return
	
	r = dir.list_dir_begin()
	
	if r != OK:
		push_error("Cannot list res://resources directory")
		return
	
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
	
	var r := file.open(file_path, File.READ)
	
	if r != OK:
		push_error("Cannot open resource file %s" % file_path)
		return
	
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
				
			elif csv_line.size() > 1:
				var str_csv_line = ""
				for item in csv_line:
					str_csv_line += item + ", "
				push_warning("Invalid game item line: %s " % [str_csv_line])
		
		line += 1
	
	file.close()
	


func get_item(id : int) -> GameItem:
	for index in range(items.size()):
		var item : GameItem = items[index]
		if item.id == id:
			return item
	push_warning("Cannot found game item [id=%d]" % id )
	return null
