@tool
extends EditorPlugin

var _dock: VBoxContainer
var _status: Label


func _enter_tree() -> void:
	_dock = VBoxContainer.new()
	_dock.name = "Zeliard Creator"
	var heading := Label.new()
	heading.text = "Zeliard Creator"
	_dock.add_child(heading)
	var validate_button := Button.new()
	validate_button.text = "Validate Content"
	validate_button.pressed.connect(_validate_content)
	_dock.add_child(validate_button)
	_status = Label.new()
	_status.text = "Ready"
	_dock.add_child(_status)
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _dock)


func _exit_tree() -> void:
	if is_instance_valid(_dock):
		remove_control_from_docks(_dock)
		_dock.queue_free()


func _validate_content() -> void:
	var catalog := ZeliardContentCatalog.load_directory("res://content")
	var resources := catalog.all()
	var invalid := ZeliardContentValidator.validate_graph(resources)
	_status.text = "%d valid resource(s)" % resources.size() if invalid.is_empty() else "%d invalid resource(s)" % invalid.size()
