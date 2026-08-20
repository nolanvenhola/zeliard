@tool
class_name ZeliardAssetDefinition
extends ZeliardContent

const SUPPORTED_ASSET_TYPES := ["sprite", "animation", "sound", "music", "font"]

@export_enum("sprite", "animation", "sound", "music", "font") var asset_type: String = "sprite"
@export_file var source_path: String = ""
@export_file var authoring_source_path: String = ""
@export var frame_size: Vector2i = Vector2i.ZERO
@export var pivot: Vector2i = Vector2i.ZERO
@export_range(1, 32) var palette_color_limit: int = 8
@export var clips: Array[ZeliardAnimationClipDefinition] = []
@export var provenance: ZeliardAssetProvenance
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
	for issue: Dictionary in asset_validation_issues():
		errors.append(String(issue["message"]))
	return errors


func asset_validation_issues() -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if provenance == null:
		issues.append(_issue(&"asset.missing_provenance", &"provenance", "provenance metadata is required"))
	else:
		issues.append_array(provenance.validation_issues())
	if not _is_pixel_art():
		return issues
	if source_path.get_extension().to_lower() != "png":
		issues.append(_issue(&"art.invalid_format", &"source_path", "pixel-art runtime export must be a PNG"))
		return issues
	var export_basename := source_path.get_file().get_basename()
	if not _is_valid_basename(export_basename):
		issues.append(_issue(&"art.invalid_name", &"source_path", "PNG basename must use lowercase snake_case"))
	if authoring_source_path.is_empty():
		issues.append(_issue(&"art.missing_authoring_source", &"authoring_source_path", "authoring_source_path is required"))
	else:
		var authoring_extension := authoring_source_path.get_extension().to_lower()
		if authoring_extension not in ["ase", "aseprite", "kra", "png"]:
			issues.append(_issue(&"art.invalid_format", &"authoring_source_path", "authoring source must use .ase, .aseprite, .kra, or .png"))
		if authoring_source_path.get_file().get_basename() != export_basename:
			issues.append(_issue(&"art.invalid_name", &"authoring_source_path", "authoring source and PNG basenames must match"))
		if not FileAccess.file_exists(authoring_source_path):
			issues.append(_issue(
				&"art.missing_authoring_source",
				&"authoring_source_path",
				"authoring source does not exist: %s" % authoring_source_path
			))
	if not FileAccess.file_exists(source_path):
		return issues
	var texture := ResourceLoader.load(source_path) as Texture2D
	var image := texture.get_image() if texture != null else null
	if image == null or image.is_empty():
		issues.append(_issue(&"art.invalid_image", &"source_path", "PNG could not be decoded"))
		return issues
	var image_size := image.get_size()
	if frame_size.x <= 0 or frame_size.y <= 0:
		issues.append(_issue(&"art.invalid_dimensions", &"frame_size", "frame_size must be positive"))
		return issues
	if frame_size.x % 8 != 0 or frame_size.y % 8 != 0:
		issues.append(_issue(&"art.off_grid", &"frame_size", "frame_size must use multiples of the 8-pixel grid"))
	if image_size.x % frame_size.x != 0 or image_size.y % frame_size.y != 0:
		issues.append(_issue(
			&"art.invalid_dimensions",
			&"frame_size",
			"PNG dimensions %s are not divisible by frame_size %s" % [image_size, frame_size]
		))
	if pivot.x < 0 or pivot.y < 0 or pivot.x >= frame_size.x or pivot.y >= frame_size.y:
		issues.append(_issue(&"art.invalid_pivot", &"pivot", "pivot must be inside one animation frame"))
	var unique_colors := _count_opaque_colors(image)
	if unique_colors > palette_color_limit:
		issues.append(_issue(
			&"art.palette_budget",
			&"palette_color_limit",
			"PNG uses %d opaque colors; declared limit is %d" % [unique_colors, palette_color_limit]
		))
	var total_frames := int(image_size.x / frame_size.x) * int(image_size.y / frame_size.y)
	var clip_names: Dictionary = {}
	for index: int in clips.size():
		var clip := clips[index]
		if clip == null:
			issues.append(_issue(&"art.invalid_clip", StringName("clips.%d" % index), "animation clip cannot be null"))
			continue
		issues.append_array(clip.validation_issues(total_frames, "clips.%d" % index))
		if clip_names.has(clip.clip_name):
			issues.append(_issue(&"art.invalid_clip", StringName("clips.%d.clip_name" % index), "duplicate clip_name %s" % clip.clip_name))
		clip_names[clip.clip_name] = true
	if asset_type == "animation" and clips.is_empty():
		issues.append(_issue(&"art.invalid_clip", &"clips", "animation asset requires at least one clip"))
	return issues


func _is_pixel_art() -> bool:
	return asset_type == "sprite" or asset_type == "animation"


func _count_opaque_colors(image: Image) -> int:
	var colors: Dictionary = {}
	for y: int in image.get_height():
		for x: int in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a8 > 0:
				colors[color.to_rgba32()] = true
	return colors.size()


func _is_valid_basename(value: String) -> bool:
	var expression := RegEx.new()
	return expression.compile("^[a-z][a-z0-9_]*$") == OK and expression.search(value) != null


func _issue(code: StringName, property_path: StringName, message: String) -> Dictionary:
	return {"code": code, "property_path": property_path, "message": message}
