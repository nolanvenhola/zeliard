class_name ZeliardContent
extends Resource

@export var content_id: StringName = &""


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if content_id.is_empty():
		errors.append("content_id is required")
	elif not _is_valid_content_id(String(content_id)):
		errors.append("content_id must use lowercase namespace:name syntax")
	return errors


static func _is_valid_content_id(value: String) -> bool:
	var expression := RegEx.new()
	var compile_error := expression.compile("^[a-z][a-z0-9_]*:[a-z][a-z0-9_]*$")
	if compile_error != OK:
		return false
	return expression.search(value) != null
