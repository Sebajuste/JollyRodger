class_name GameItemGeneration
extends Object



var number_generator := RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _init():
	
	number_generator.randomize()
	
	pass # Replace with function body.


func generate_item(item_id := -1):
	
	var item_description := {
		"item_id": determine_type() if item_id == -1 else item_id,
		"item_rarity": determine_rarity(),
		"quantity": 1,
		"attributes": {}
	}
	
	for attribut in GameItem.ATTRIBUTS_TYPE:
		var item := GameTable.get_item(item_description.item_id)
		if item.attributes.has(attribut):
			item_description.attributes[attribut] = determine_stat(item, item_description.item_rarity, attribut)
	
	return item_description


func determine_type():
	var item : GameItem = GameTable.items[ number_generator.randi() % GameTable.items.size() ]
	return item.id
	


func determine_rarity() -> String:
	var item_rarity := "Common"
	var item_rarities := GameTable.item_rarity_distribution.keys()
	
	var rarity_roll := number_generator.randi() % 100 + 1
	for i in item_rarities:
		
		if rarity_roll < GameTable.item_rarity_distribution[i]:
			item_rarity = i
			break
		else:
			rarity_roll -= GameTable.item_rarity_distribution[i]
	
	return item_rarity


func determine_suffix():
	pass


func determine_stat(item : GameItem, rarity : String, stat):
	var key := rarity.to_lower() + "_multi"
	if item.rarity_mult.has(key):
		return item.attributes[stat] * item.rarity_mult[key]
	else:
		return item.attributes[stat]
	
