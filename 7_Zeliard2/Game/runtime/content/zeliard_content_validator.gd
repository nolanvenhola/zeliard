class_name ZeliardContentValidator
extends RefCounted


static func validate(content: ZeliardContent) -> PackedStringArray:
	if content == null:
		return PackedStringArray(["content resource is required"])
	return content.validation_errors()


static func validate_all(resources: Array[ZeliardContent]) -> Dictionary:
	var invalid: Dictionary = {}
	for content: ZeliardContent in resources:
		var errors := validate(content)
		if not errors.is_empty():
			var key := content.content_id if content != null else &"<null>"
			invalid[key] = errors
	return invalid
