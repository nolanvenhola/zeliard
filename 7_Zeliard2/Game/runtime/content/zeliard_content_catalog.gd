class_name ZeliardContentCatalog
extends RefCounted

var _resources: Array[ZeliardContent] = []
var _by_id: Dictionary = {}


func add(content: ZeliardContent) -> void:
	_resources.append(content)
	if content != null and not _by_id.has(content.content_id):
		_by_id[content.content_id] = content


func all() -> Array[ZeliardContent]:
	return _resources.duplicate()


func get_by_id(content_id: StringName) -> ZeliardContent:
	return _by_id.get(content_id) as ZeliardContent


func contains(content_id: StringName) -> bool:
	return _by_id.has(content_id)


static func load_directory(root: String) -> ZeliardContentCatalog:
	var catalog := ZeliardContentCatalog.new()
	_load_directory_into(catalog, root)
	return catalog


static func _load_directory_into(catalog: ZeliardContentCatalog, root: String) -> void:
	var files := DirAccess.get_files_at(root)
	files.sort()
	for file_name: String in files:
		if file_name.get_extension() != "tres":
			continue
		var loaded := ResourceLoader.load(root.path_join(file_name))
		if loaded is ZeliardContent:
			catalog.add(loaded as ZeliardContent)
	var directories := DirAccess.get_directories_at(root)
	directories.sort()
	for directory_name: String in directories:
		if not directory_name.begins_with("."):
			_load_directory_into(catalog, root.path_join(directory_name))
