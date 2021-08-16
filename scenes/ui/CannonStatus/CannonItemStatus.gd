extends HBoxContainer


onready var progress_bar := $ProgressBar


var cannon : AbstractCannon setget set_cannon


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_cannon(_cannon):
	cannon = _cannon
	var _r
	_r = cannon.connect("fired", self, "_on_fired")
	_r = cannon.connect("reloaded", self, "_on_reloaded")
	if cannon.fire_ready:
		_on_reloaded()


func _on_fired():
	progress_bar.max_value = int(60.0 / cannon.fire_rate)
	progress_bar.value = 0
	$Tween.interpolate_property(progress_bar, "value",
		0,  100, (60.0 / cannon.fire_rate) * 10,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	$Tween.start()


func _on_reloaded():
	
	progress_bar.value = progress_bar.max_value
	
