@tool
class_name ZeliardEventStep
extends Resource

const SUPPORTED_ACTIONS := [
	"show_dialogue",
	"give_item",
	"start_quest",
	"complete_quest",
	"move_to_room",
	"set_flag",
]

@export_enum("show_dialogue", "give_item", "start_quest", "complete_quest", "move_to_room", "set_flag")
var action: String = "show_dialogue"
@export var target_content_id: StringName = &""
@export var flag_id: StringName = &""
@export var flag_value: bool = true


func expected_target_kind() -> StringName:
	match action:
		"show_dialogue":
			return ZeliardContentKinds.DIALOGUE
		"give_item":
			return ZeliardContentKinds.ITEM
		"start_quest", "complete_quest":
			return ZeliardContentKinds.QUEST
		"move_to_room":
			return ZeliardContentKinds.ROOM
		_:
			return &""


func reference_field_kinds() -> Dictionary:
	var kind := expected_target_kind()
	return {} if kind.is_empty() else {&"target_content_id": kind}


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if not SUPPORTED_ACTIONS.has(action):
		errors.append("unsupported event action %s" % action)
	if action == "set_flag" and flag_id.is_empty():
		errors.append("set_flag requires flag_id")
	elif action != "set_flag" and target_content_id.is_empty():
		errors.append("%s requires target_content_id" % action)
	return errors
