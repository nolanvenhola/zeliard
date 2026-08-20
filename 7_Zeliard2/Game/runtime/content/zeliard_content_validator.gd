@tool
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
	var invalid: Dictionary = {}
	for diagnostic: ZeliardDiagnostic in diagnose_graph(resources):
		_append_error(invalid, diagnostic.owner_id, diagnostic.message)
	return invalid


static func diagnose_graph(resources: Array[ZeliardContent]) -> Array[ZeliardDiagnostic]:
	var diagnostics: Array[ZeliardDiagnostic] = []
	var index: Dictionary = {}
	for content: ZeliardContent in resources:
		if content == null:
			diagnostics.append(_diagnostic(null, &"content.null_definition", &"", "content resource is required"))
			continue
		var specialized_messages: Dictionary = {}
		if content is ZeliardAssetDefinition:
			for issue: Dictionary in (content as ZeliardAssetDefinition).asset_validation_issues():
				var message := String(issue["message"])
				specialized_messages[message] = true
				diagnostics.append(_diagnostic(
					content,
					issue["code"] as StringName,
					issue["property_path"] as StringName,
					message
				))
		for message: String in validate(content):
			if not specialized_messages.has(message):
				diagnostics.append(_diagnostic(content, &"content.invalid_definition", &"", message))
		if content.content_id.is_empty():
			continue
		if index.has(content.content_id):
			diagnostics.append(_diagnostic(content, &"content.duplicate_id", &"content_id", "duplicate content_id"))
		else:
			index[content.content_id] = content
	for owner: ZeliardContent in resources:
		if owner == null:
			continue
		for reference: ZeliardContentReference in owner.content_references():
			if not index.has(reference.target_id):
				diagnostics.append(_diagnostic(
					owner,
					&"content.missing_reference",
					reference.owner_field,
					"%s references missing %s ID %s" % [reference.owner_field, reference.expected_kind, reference.target_id]
				))
				continue
			var target := index[reference.target_id] as ZeliardContent
			if target.content_kind() != reference.expected_kind:
				diagnostics.append(_diagnostic(
					owner,
					&"content.wrong_reference_kind",
					reference.owner_field,
					"%s expects %s ID but %s is %s" % [reference.owner_field, reference.expected_kind, reference.target_id, target.content_kind()]
				))
	diagnostics.sort_custom(func(left: ZeliardDiagnostic, right: ZeliardDiagnostic) -> bool: return left.format() < right.format())
	return diagnostics


static func _append_error(invalid: Dictionary, owner_id: StringName, message: String) -> void:
	var errors := invalid.get(owner_id, PackedStringArray()) as PackedStringArray
	errors.append(message)
	invalid[owner_id] = errors


static func _diagnostic(
	owner: ZeliardContent,
	code: StringName,
	property_path: StringName,
	message: String
) -> ZeliardDiagnostic:
	var owner_id := owner.content_id if owner != null else &"<null>"
	var owner_path := owner.resource_path if owner != null else ""
	return ZeliardDiagnostic.new(ZeliardDiagnostic.ERROR, code, owner_id, owner_path, property_path, message)
