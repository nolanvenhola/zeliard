@tool
class_name ZeliardCreatorDirtyTracker
extends RefCounted

var _paths: Dictionary = {}


func mark(path: String) -> void:
	if not path.is_empty():
		_paths[path] = true


func clear(path: String) -> void:
	_paths.erase(path)


func clear_all() -> void:
	_paths.clear()


func contains(path: String) -> bool:
	return _paths.has(path)


func paths() -> PackedStringArray:
	var result := PackedStringArray(_paths.keys())
	result.sort()
	return result


func status_text() -> String:
	var count := _paths.size()
	return "" if count == 0 else "%d unsaved Zeliard content resource(s)" % count
