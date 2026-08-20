class_name ZeliardAbilityDefinition
extends ZeliardContent

const SUPPORTED_ABILITY_TYPES := ["melee", "projectile", "movement", "utility"]

@export_enum("melee", "projectile", "movement", "utility") var ability_type: String = "melee"
@export_range(0, 999) var power: int = 0
@export_range(0, 1200) var cooldown_steps: int = 0
@export_range(0, 64) var range_cells: int = 0
@export var effect_event_id: StringName = &""
@export var animation_asset_id: StringName = &""
@export var audio_asset_id: StringName = &""


func content_kind() -> StringName:
	return ZeliardContentKinds.ABILITY


func validation_errors() -> PackedStringArray:
	var errors := super()
	if not SUPPORTED_ABILITY_TYPES.has(ability_type):
		errors.append("unsupported ability_type %s" % ability_type)
	if power < 0 or cooldown_steps < 0 or range_cells < 0:
		errors.append("ability numeric values cannot be negative")
	return errors


func content_references() -> Array[ZeliardContentReference]:
	var references: Array[ZeliardContentReference] = []
	_append_reference(references, &"effect_event_id", effect_event_id, ZeliardContentKinds.EVENT)
	_append_reference(references, &"animation_asset_id", animation_asset_id, ZeliardContentKinds.ASSET)
	_append_reference(references, &"audio_asset_id", audio_asset_id, ZeliardContentKinds.ASSET)
	return references
