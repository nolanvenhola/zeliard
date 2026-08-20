@tool
class_name ZeliardAssetDefinition
extends ZeliardContent

const SUPPORTED_ASSET_TYPES := ["sprite", "animation", "sound", "music", "font"]

@export_enum("sprite", "animation", "sound", "music", "font") var asset_type: String = "sprite"
@export_file var source_path: String = ""
@export var authoring_notes: String = ""


func content_kind() -> StringName:
	return ZeliardContentKinds.ASSET


func validation_errors() -> PackedStringArray:
	var errors := super()
	if not SUPPORTED_ASSET_TYPES.has(asset_type):
		errors.append("unsupported asset_type %s" % asset_type)
	if source_path.is_empty():
		errors.append("source_path is required")
	elif not ResourceLoader.exists(source_path):
		errors.append("source_path does not exist: %s" % source_path)
	return errors
