extends Spatial


onready var player = $SwedishRoyalYachtAmadis


# Called when the node enters the scene tree for the first time.
func _ready():
	
	player.flag.faction = "GB"
	
	$CapureZone.faction = "Pirate"
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _unhandled_input(event):
	
	if event.is_action_pressed("fire_order"):
		
		var target : Spatial = $SelectorHandler.get_target()
		
		if target:
			for canon in player.get_node("Cannons").get_children():
				var target_pos := target.global_transform.origin + Vector3.UP * 3.0
				
				var target_velocity := Vector3.ZERO
				
				if target.has_meta("linear_velocity"):
					target_velocity = target.linear_velocity
				
				if canon.fire_ready and canon.is_in_range(target_pos):
					canon.fire_delay = rand_range(0.0, 0.5)
					canon.fire(target_pos, target_velocity)
	
