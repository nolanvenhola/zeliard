@tool
class_name ZeliardDialogueLine
extends Resource

@export var line_id: StringName = &""
@export var speaker_actor_id: StringName = &""
@export_multiline var text: String = ""


func reference_field_kinds() -> Dictionary:
	return {&"speaker_actor_id": ZeliardContentKinds.ACTOR}
