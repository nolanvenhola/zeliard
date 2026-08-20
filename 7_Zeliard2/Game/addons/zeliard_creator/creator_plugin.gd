@tool
extends EditorPlugin

var _dock: ZeliardCreatorDock
var _index := ZeliardCreatorCatalogIndex.new()
var _dirty := ZeliardCreatorDirtyTracker.new()
var _catalog := ZeliardContentCatalog.new()
var _inspector_plugin: ZeliardContentInspectorPlugin
var _specialized_editors: Dictionary = {}


func _enter_tree() -> void:
	_reload_catalog()
	_inspector_plugin = ZeliardContentInspectorPlugin.new(_index)
	add_inspector_plugin(_inspector_plugin)
	_dock = ZeliardCreatorDock.new()
	_dock.setup(_index, _dirty)
	_dock.refresh_requested.connect(_reload_catalog)
	_dock.validate_requested.connect(_validate_content)
	_dock.create_requested.connect(_create_content)
	_dock.content_activated.connect(_edit_content)
	_dock.diagnostic_activated.connect(_open_diagnostic)
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _dock)
	resource_saved.connect(_on_resource_saved)
	EditorInterface.get_resource_filesystem().filesystem_changed.connect(_on_filesystem_changed)
	_validate_content()


func _exit_tree() -> void:
	var filesystem := EditorInterface.get_resource_filesystem()
	if filesystem.filesystem_changed.is_connected(_on_filesystem_changed):
		filesystem.filesystem_changed.disconnect(_on_filesystem_changed)
	if resource_saved.is_connected(_on_resource_saved):
		resource_saved.disconnect(_on_resource_saved)
	if _inspector_plugin != null:
		remove_inspector_plugin(_inspector_plugin)
	if is_instance_valid(_dock):
		remove_control_from_docks(_dock)
		_dock.queue_free()


func _get_unsaved_status(for_scene: String) -> String:
	return _dirty.status_text() if for_scene.is_empty() else ""


func _save_external_data() -> void:
	for path: String in _dirty.paths():
		var resource := ResourceLoader.load(path)
		if resource != null and ResourceSaver.save(resource, path) == OK:
			_dirty.clear(path)
	_dock.refresh()


func register_specialized_editor(kind: StringName, handler: Callable) -> void:
	_specialized_editors[kind] = handler


func unregister_specialized_editor(kind: StringName) -> void:
	_specialized_editors.erase(kind)


func _reload_catalog() -> void:
	_catalog = ZeliardContentCatalog.load_directory("res://content")
	_index.rebuild(_catalog)
	for content: ZeliardContent in _catalog.all():
		var callback := _on_content_changed.bind(content.resource_path)
		if not content.changed.is_connected(callback):
			content.changed.connect(callback)
	if is_instance_valid(_dock):
		_dock.refresh()


func _validate_content() -> void:
	_reload_catalog()
	_dock.show_diagnostics(ZeliardContentValidator.diagnose_graph(_catalog.all()))


func _create_content(kind: StringName, content_id: StringName, display_name: String) -> void:
	if _catalog.contains(content_id):
		_dock.set_status("Stable ID already exists: %s" % content_id)
		return
	var content := ZeliardCreatorTemplateFactory.create(kind, content_id, display_name, _catalog)
	if content == null:
		_dock.set_status("Unsupported content kind: %s" % kind)
		return
	var errors := content.validation_errors()
	if not errors.is_empty():
		_dock.set_status("Cannot create resource: %s" % "; ".join(errors))
		return
	var graph := _catalog.all()
	graph.append(content)
	var diagnostics := ZeliardContentValidator.diagnose_graph(graph)
	if not diagnostics.is_empty():
		_dock.set_status("Cannot create resource: %s" % diagnostics[0].message)
		return
	var path := ZeliardCreatorTemplateFactory.output_path(content)
	if ResourceLoader.exists(path):
		_dock.set_status("File already exists: %s" % path)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var error := ResourceSaver.save(content, path)
	if error != OK:
		_dock.set_status("Could not save %s (error %d)" % [path, error])
		return
	EditorInterface.get_resource_filesystem().scan()
	_reload_catalog()
	_dock.set_status("Created %s" % content_id)
	_edit_content(ResourceLoader.load(path) as ZeliardContent)


func _edit_content(content: ZeliardContent) -> void:
	if content == null:
		return
	var handler := _specialized_editors.get(content.content_kind(), Callable()) as Callable
	if handler.is_valid():
		handler.call(content)
		return
	EditorInterface.select_file(content.resource_path)
	EditorInterface.edit_resource(content)


func _open_diagnostic(diagnostic: ZeliardDiagnostic) -> void:
	if diagnostic.owner_path.is_empty():
		return
	var resource := ResourceLoader.load(diagnostic.owner_path)
	if resource == null:
		return
	EditorInterface.select_file(diagnostic.owner_path)
	EditorInterface.inspect_object(resource, String(diagnostic.property_path))


func _on_content_changed(path: String) -> void:
	_dirty.mark(path)
	if is_instance_valid(_dock):
		_dock.refresh()


func _on_resource_saved(resource: Resource) -> void:
	_dirty.clear(resource.resource_path)
	if is_instance_valid(_dock):
		_dock.refresh()


func _on_filesystem_changed() -> void:
	call_deferred(&"_reload_catalog")
