class_name DetectionArea
extends Area

signal detection_changed()
signal object_detected(objet)
signal object_undetected(object)


export var group_name := ""


var detected_objects := []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DetectionArea_body_entered(body : Spatial):
	if body.is_in_group(group_name):
		detected_objects.append(body)
		emit_signal("object_detected", body)
		emit_signal("detection_changed")


func _on_DetectionArea_body_exited(body):
	var index = detected_objects.find(body)
	if index != -1:
		detected_objects.remove(index)
		emit_signal("object_undetected", body)
		emit_signal("detection_changed")
	
