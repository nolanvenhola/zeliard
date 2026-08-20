class_name ZeliardLog
extends RefCounted

enum Level {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
}

static var _test_sink: Callable = Callable()


static func debug(event: StringName, fields: Dictionary = {}) -> void:
	_write(Level.DEBUG, event, fields)


static func info(event: StringName, fields: Dictionary = {}) -> void:
	_write(Level.INFO, event, fields)


static func warning(event: StringName, fields: Dictionary = {}) -> void:
	_write(Level.WARNING, event, fields)


static func error(event: StringName, fields: Dictionary = {}) -> void:
	_write(Level.ERROR, event, fields)


static func set_test_sink(sink: Callable) -> void:
	_test_sink = sink


static func clear_test_sink() -> void:
	_test_sink = Callable()


static func _write(level: Level, event: StringName, fields: Dictionary) -> void:
	var record: Dictionary = {
		"event": String(event),
		"fields": fields.duplicate(true),
		"level": Level.keys()[level].to_lower(),
	}
	if _test_sink.is_valid():
		_test_sink.call(record)
		return
	print(JSON.stringify(record))
