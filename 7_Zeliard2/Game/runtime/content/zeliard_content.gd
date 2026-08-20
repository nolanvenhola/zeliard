class_name ZeliardContent
extends Resource

const CURRENT_SCHEMA_VERSION: int = 1

@export_range(1, 999) var schema_version: int = CURRENT_SCHEMA_VERSION
@export var content_id: StringName = &""
@export var display_name: String = ""


func content_kind() -> StringName:
	return ZeliardContentKinds.CONTENT


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if schema_version != CURRENT_SCHEMA_VERSION:
		errors.append("unsupported content schema_version %d" % schema_version)
	if content_id.is_empty():
		errors.append("content_id is required")
	elif not _is_valid_content_id(String(content_id)):
		errors.append("content_id must use lowercase namespace:name syntax")
	elif content_kind() != ZeliardContentKinds.CONTENT and String(content_id).get_slice(":", 0) != String(content_kind()):
		errors.append("content_id namespace must match content kind %s" % content_kind())
	if display_name.strip_edges().is_empty():
		errors.append("display_name is required")
	return errors


func content_references() -> Array[ZeliardContentReference]:
	return []


func _append_reference(
	references: Array[ZeliardContentReference],
	field: StringName,
	target_id: StringName,
	expected_kind: StringName
) -> void:
	if not target_id.is_empty():
		references.append(ZeliardContentReference.new(field, target_id, expected_kind))


static func _is_valid_content_id(value: String) -> bool:
	var expression := RegEx.new()
	var compile_error := expression.compile("^[a-z][a-z0-9_]*:[a-z][a-z0-9_]*$")
	if compile_error != OK:
		return false
	return expression.search(value) != null
