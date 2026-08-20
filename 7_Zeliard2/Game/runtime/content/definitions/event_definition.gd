class_name ZeliardEventDefinition
extends ZeliardContent

const SUPPORTED_TRIGGERS := ["room_enter", "interact", "enemy_defeated", "quest_changed"]

@export_enum("room_enter", "interact", "enemy_defeated", "quest_changed") var trigger: String = "interact"
@export var once: bool = true
@export var steps: Array[ZeliardEventStep] = []


func content_kind() -> StringName:
	return ZeliardContentKinds.EVENT


func validation_errors() -> PackedStringArray:
	var errors := super()
	if not SUPPORTED_TRIGGERS.has(trigger):
		errors.append("unsupported trigger %s" % trigger)
	if steps.is_empty():
		errors.append("event requires at least one step")
	for step: ZeliardEventStep in steps:
		if step == null:
			errors.append("event step cannot be null")
		else:
			errors.append_array(step.validation_errors())
	return errors


func content_references() -> Array[ZeliardContentReference]:
	var references: Array[ZeliardContentReference] = []
	for step: ZeliardEventStep in steps:
		if step != null:
			_append_reference(references, &"steps.target_content_id", step.target_content_id, step.expected_target_kind())
	return references
