class_name StateMachine
extends Node



class NextState:
	var target_state_path: String
	var msg: Dictionary = {}


signal transitioned(state_path, msg)


export var initial_state: = NodePath()
export var enable := true


onready var state: Node = get_node(initial_state) setget set_state

var _state_name: String


var _next_state : NextState


func _init() -> void:
	
	add_to_group("state_machine")
	


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	
	#state = get_node(initial_state)
	
	_state_name = state.name
	state.enter()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not enable:
		return
	
	state.process(delta)
	
	if _next_state != null:
		var next_state = _next_state
		_next_state = null
		_process_transition(next_state)
	


func _physics_process(delta):
	if enable:
		state.physics_process(delta)
	


func _unhandled_input(event: InputEvent):
	if enable:
		state.unhandled_input(event)
	


func transition_to(target_state_path: String, msg: Dictionary = {}):
	_next_state = NextState.new()
	_next_state.target_state_path = target_state_path
	_next_state.msg = msg


func _process_transition(next_state : NextState):
	var target_state_path: String = next_state.target_state_path
	var msg: Dictionary = next_state.msg
	if not has_node(target_state_path):
		push_error("State %s not exists" % target_state_path )
		return
	var target_state: = get_node(target_state_path)
	
	if not target_state or self.state == target_state:
		push_error("Invalid State %s" % target_state_path)
		return
	
	if self.state:
		self.state.exit()
	self.state = target_state
	self.state.enter(msg)
	emit_signal("transitioned", target_state_path, msg)


func set_state(value: Node):
	if value:
		state = value
		_state_name = state.name
