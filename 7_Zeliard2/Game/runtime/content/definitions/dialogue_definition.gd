@tool
class_name ZeliardDialogueDefinition
extends ZeliardContent

@export var lines: Array[ZeliardDialogueLine] = []


func content_kind() -> StringName:
	return ZeliardContentKinds.DIALOGUE


func validation_errors() -> PackedStringArray:
	var errors := super()
	var line_ids: Dictionary = {}
	if lines.is_empty():
		errors.append("dialogue requires at least one line")
	for line: ZeliardDialogueLine in lines:
		if line == null or line.line_id.is_empty() or line.text.strip_edges().is_empty():
			errors.append("every dialogue line requires line_id and text")
			continue
		if line_ids.has(line.line_id):
			errors.append("duplicate dialogue line_id %s" % line.line_id)
		line_ids[line.line_id] = true
	return errors


func content_references() -> Array[ZeliardContentReference]:
	var references: Array[ZeliardContentReference] = []
	for line: ZeliardDialogueLine in lines:
		if line != null:
			_append_reference(references, &"lines.speaker_actor_id", line.speaker_actor_id, ZeliardContentKinds.ACTOR)
	return references
