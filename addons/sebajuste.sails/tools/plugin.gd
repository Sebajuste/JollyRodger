tool
extends EditorPlugin


const MENU_4_POINTS_SAIL := 0
const MENU_3_POINTS_SAIL := 1

const SailInspector = preload("res://addons/sebajuste.sails/tools/sail_inspector.gd")
const SailGizmoPlugin = preload("SailGizmoPlugin.gd")


var sail_gizmo_plugin = SailGizmoPlugin.new()
var sail_inspector = SailInspector.new()

var _toolbar = null

var _edit_sail = null


func _enter_tree():
	
	add_custom_type("Sail", "Spatial", Sail, null)
	
	add_spatial_gizmo_plugin(sail_gizmo_plugin)
	add_inspector_plugin(sail_inspector)
	
	_toolbar = HBoxContainer.new()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _toolbar)
	_toolbar.set_visible(false)
	
	_toolbar.add_child(VSeparator.new())
	
	var menu := MenuButton.new()
	menu.set_text("Sails")
	
	menu.get_popup().add_item("Create 4 points sail", MENU_4_POINTS_SAIL)
	menu.get_popup().add_item("Create 3 points sail", MENU_3_POINTS_SAIL)
	
	menu.get_popup().connect("id_pressed", self, "_on_menu_item_selected")
	
	_toolbar.add_child(menu)
	#_menu_button = menu
	
	"""
	var mode_group := ButtonGroup.new()
	
	var button := ToolButton.new()
	button.icon = load("res://addons/sebajuste.sails/tools/icons/Add.svg")
	button.set_tooltip("Add")
	button.set_toggle_mode(true)
	button.set_button_group(mode_group)
	button.connect("pressed", self, "_on_mode_selected", ["Add"])
	
	_toolbar.add_child(button)
	"""


func _exit_tree():
	
	remove_spatial_gizmo_plugin(sail_gizmo_plugin)
	remove_inspector_plugin(sail_inspector)
	_toolbar.queue_free()
	_toolbar = null


func handles(object):
	
	return _get_sail_from_object(object)
	

func make_visible(visible: bool):
	
	_toolbar.set_visible(visible)
	


func edit(object):
	
	_edit_sail = _get_sail_from_object(object)
	


static func _get_sail_from_object(object):
	if object != null and object is Spatial:
		if not object.is_inside_tree():
			return null
		if object is Sail:
			return object
	return null


func _on_menu_item_selected(id : int):
	
	match id:
		MENU_4_POINTS_SAIL:
			_edit_sail.update_gizmo()
			pass
		MENU_3_POINTS_SAIL:
			_edit_sail.update_gizmo()
			pass
		_:
			push_warning("[SailPlugin] ID action not found : %d" % id)
	
	pass

"""
func _on_mode_selected(mode):
	
	print("_on_mode_selected : ", mode)
	
	pass
"""
