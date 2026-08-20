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


static func validate_graph(resources: Array[ZeliardContent]) -> Dictionary:
	var invalid := validate_all(resources)
	var index: Dictionary = {}
	for content: ZeliardContent in resources:
		if content == null or content.content_id.is_empty():
			continue
		if index.has(content.content_id):
			_append_error(invalid, content.content_id, "duplicate content_id")
		else:
			index[content.content_id] = content
	for owner: ZeliardContent in resources:
		if owner == null:
			continue
		for reference: ZeliardContentReference in owner.content_references():
			if not index.has(reference.target_id):
				_append_error(
					invalid,
					owner.content_id,
					"%s references missing %s ID %s" % [reference.owner_field, reference.expected_kind, reference.target_id]
				)
				continue
			var target := index[reference.target_id] as ZeliardContent
			if target.content_kind() != reference.expected_kind:
				_append_error(
					invalid,
					owner.content_id,
					"%s expects %s ID but %s is %s" % [reference.owner_field, reference.expected_kind, reference.target_id, target.content_kind()]
				)
	return invalid


static func _append_error(invalid: Dictionary, owner_id: StringName, message: String) -> void:
	var errors := invalid.get(owner_id, PackedStringArray()) as PackedStringArray
	errors.append(message)
	invalid[owner_id] = errors
