class_name ZeliardDiagnostic
extends RefCounted

const ERROR: StringName = &"error"
const WARNING: StringName = &"warning"

var severity: StringName
var code: StringName
var owner_id: StringName
var owner_path: String
var property_path: StringName
var message: String


func _init(
	p_severity: StringName,
	p_code: StringName,
	p_owner_id: StringName,
	p_owner_path: String,
	p_property_path: StringName,
	p_message: String
) -> void:
	severity = p_severity
	code = p_code
	owner_id = p_owner_id
	owner_path = p_owner_path
	property_path = p_property_path
	message = p_message


func format() -> String:
	var location := owner_path if not owner_path.is_empty() else "<memory>"
	var owner := String(owner_id) if not owner_id.is_empty() else "<unknown>"
	var property_suffix := ".%s" % property_path if not property_path.is_empty() else ""
	return "%s [%s] %s (%s%s): %s" % [String(severity).to_upper(), code, location, owner, property_suffix, message]


func to_dictionary() -> Dictionary:
	return {
		"code": String(code),
		"message": message,
		"owner_id": String(owner_id),
		"owner_path": owner_path,
		"property_path": String(property_path),
		"severity": String(severity),
	}
