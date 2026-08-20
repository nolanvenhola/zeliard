@tool
class_name ZeliardQuestStage
extends Resource

@export var stage_id: StringName = &""
@export var description: String = ""
@export var completion_event_id: StringName = &""


func reference_field_kinds() -> Dictionary:
	return {&"completion_event_id": ZeliardContentKinds.EVENT}
