class_name ZeliardSaveCodec
extends RefCounted

const FORMAT_NAME: String = "zeliard2-save"


static func encode(data: ZeliardSaveData) -> String:
	var canonical_payload_text := JSON.stringify(data.to_dictionary(), "", true)
	var payload := JSON.parse_string(canonical_payload_text) as Dictionary
	var envelope := {
		"checksum": _checksum(payload),
		"format": FORMAT_NAME,
		"payload": payload,
	}
	return JSON.stringify(envelope, "\t", true)


static func decode(text: String) -> ZeliardSaveDecodeResult:
	var result := ZeliardSaveDecodeResult.new()
	var json := JSON.new()
	var parse_error := json.parse(text)
	if parse_error != OK:
		result.error_message = "invalid JSON at line %d: %s" % [json.get_error_line(), json.get_error_message()]
		return result
	if not json.data is Dictionary:
		result.error_message = "save root must be an object"
		return result
	var root := json.data as Dictionary
	var payload: Dictionary
	if root.has("payload") or root.has("checksum") or root.has("format"):
		if root.get("format", "") != FORMAT_NAME:
			result.error_message = "unsupported save format"
			return result
		if not root.get("payload") is Dictionary or not root.get("checksum") is String:
			result.error_message = "save envelope is incomplete"
			return result
		payload = (root["payload"] as Dictionary).duplicate(true)
		if not _constant_time_equal(String(root["checksum"]), _checksum(payload)):
			result.error_message = "save checksum does not match payload"
			return result
	else:
		payload = root.duplicate(true)
	var migration := ZeliardSaveMigrator.migrate(payload)
	if not migration.success:
		result.error_message = migration.error_message
		return result
	var shape_error := _payload_shape_error(migration.payload)
	if not shape_error.is_empty():
		result.error_message = shape_error
		return result
	var data := ZeliardSaveData.from_dictionary(migration.payload)
	var validation_errors := data.validation_errors()
	if not validation_errors.is_empty():
		result.error_message = "; ".join(validation_errors)
		return result
	result.success = true
	result.data = data
	result.migrated_from_version = migration.migrated_from_version
	return result


static func _payload_shape_error(payload: Dictionary) -> String:
	var required := PackedStringArray([
		"schema_version", "campaign_id", "current_room_id", "player_health",
		"inventory_ids", "quest_stages", "flags",
	])
	for key: String in required:
		if not payload.has(key):
			return "save payload is missing %s" % key
	if not payload["campaign_id"] is String or not payload["current_room_id"] is String:
		return "campaign_id and current_room_id must be strings"
	if not payload["player_health"] is float and not payload["player_health"] is int:
		return "player_health must be numeric"
	if not payload["inventory_ids"] is Array:
		return "inventory_ids must be an array"
	for item_id: Variant in payload["inventory_ids"]:
		if not item_id is String:
			return "inventory_ids entries must be strings"
	if not payload["quest_stages"] is Dictionary or not payload["flags"] is Dictionary:
		return "quest_stages and flags must be objects"
	return ""


static func _checksum(payload: Dictionary) -> String:
	var canonical := JSON.stringify(payload, "", true)
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		return ""
	context.update(canonical.to_utf8_buffer())
	return context.finish().hex_encode()


static func _constant_time_equal(left: String, right: String) -> bool:
	var left_bytes := left.to_utf8_buffer()
	var right_bytes := right.to_utf8_buffer()
	var difference := left_bytes.size() ^ right_bytes.size()
	var count := maxi(left_bytes.size(), right_bytes.size())
	for index: int in count:
		var left_value := left_bytes[index] if index < left_bytes.size() else 0
		var right_value := right_bytes[index] if index < right_bytes.size() else 0
		difference |= left_value ^ right_value
	return difference == 0
