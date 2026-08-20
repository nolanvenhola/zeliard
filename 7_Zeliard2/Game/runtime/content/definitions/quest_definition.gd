class_name ZeliardQuestDefinition
extends ZeliardContent

@export var prerequisite_quest_ids := PackedStringArray()
@export var stages: Array[ZeliardQuestStage] = []
@export var reward_item_ids := PackedStringArray()


func content_kind() -> StringName:
	return ZeliardContentKinds.QUEST


func validation_errors() -> PackedStringArray:
	var errors := super()
	var stage_ids: Dictionary = {}
	if stages.is_empty():
		errors.append("quest requires at least one stage")
	for stage: ZeliardQuestStage in stages:
		if stage == null or stage.stage_id.is_empty() or stage.description.strip_edges().is_empty():
			errors.append("every quest stage requires stage_id and description")
			continue
		if stage_ids.has(stage.stage_id):
			errors.append("duplicate quest stage_id %s" % stage.stage_id)
		stage_ids[stage.stage_id] = true
	return errors


func content_references() -> Array[ZeliardContentReference]:
	var references: Array[ZeliardContentReference] = []
	for quest_id: String in prerequisite_quest_ids:
		_append_reference(references, &"prerequisite_quest_ids", StringName(quest_id), ZeliardContentKinds.QUEST)
	for stage: ZeliardQuestStage in stages:
		if stage != null:
			_append_reference(references, &"stages.completion_event_id", stage.completion_event_id, ZeliardContentKinds.EVENT)
	for item_id: String in reward_item_ids:
		_append_reference(references, &"reward_item_ids", StringName(item_id), ZeliardContentKinds.ITEM)
	return references
