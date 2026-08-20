class_name ZeliardContentReference
extends RefCounted

var owner_field: StringName
var target_id: StringName
var expected_kind: StringName


func _init(
	p_owner_field: StringName,
	p_target_id: StringName,
	p_expected_kind: StringName
) -> void:
	owner_field = p_owner_field
	target_id = p_target_id
	expected_kind = p_expected_kind
