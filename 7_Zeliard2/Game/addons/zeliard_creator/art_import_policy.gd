@tool
class_name ZeliardArtImportPolicy
extends RefCounted

const EXPECTED_PARAMETERS := {
	"compress/mode": 0,
	"mipmaps/generate": false,
	"process/fix_alpha_border": false,
	"process/premult_alpha": false,
	"process/size_limit": 0,
	"detect_3d/compress_to": 0,
}


static func diagnose_catalog(catalog: ZeliardContentCatalog) -> Array[ZeliardDiagnostic]:
	var diagnostics: Array[ZeliardDiagnostic] = []
	for content: ZeliardContent in catalog.all():
		if content is ZeliardAssetDefinition:
			diagnostics.append_array(diagnose(content as ZeliardAssetDefinition))
	diagnostics.sort_custom(func(left: ZeliardDiagnostic, right: ZeliardDiagnostic) -> bool: return left.format() < right.format())
	return diagnostics


static func diagnose(asset: ZeliardAssetDefinition) -> Array[ZeliardDiagnostic]:
	var diagnostics: Array[ZeliardDiagnostic] = []
	if asset.asset_type != "sprite" and asset.asset_type != "animation":
		return diagnostics
	if asset.source_path.get_extension().to_lower() != "png":
		return diagnostics
	var import_path := asset.source_path + ".import"
	var config := ConfigFile.new()
	if config.load(import_path) != OK:
		diagnostics.append(_diagnostic(asset, "missing Godot texture import metadata for %s" % asset.source_path))
		return diagnostics
	if config.get_value("remap", "importer", "") != "texture":
		diagnostics.append(_diagnostic(asset, "PNG must use Godot's texture importer"))
	for parameter: String in EXPECTED_PARAMETERS:
		var actual: Variant = config.get_value("params", parameter) if config.has_section_key("params", parameter) else null
		var expected: Variant = EXPECTED_PARAMETERS[parameter]
		if actual != expected:
			diagnostics.append(_diagnostic(
				asset,
				"%s must be %s (got %s)" % [parameter, expected, actual]
			))
	return diagnostics


static func apply(asset: ZeliardAssetDefinition) -> bool:
	if asset.asset_type != "sprite" and asset.asset_type != "animation":
		return false
	if asset.source_path.get_extension().to_lower() != "png":
		return false
	var import_path := asset.source_path + ".import"
	var config := ConfigFile.new()
	if config.load(import_path) != OK:
		return false
	var changed := false
	for parameter: String in EXPECTED_PARAMETERS:
		var expected: Variant = EXPECTED_PARAMETERS[parameter]
		var actual: Variant = config.get_value("params", parameter) if config.has_section_key("params", parameter) else null
		if actual != expected:
			config.set_value("params", parameter, expected)
			changed = true
	if changed and config.save(import_path) != OK:
		return false
	return changed


static func apply_catalog(catalog: ZeliardContentCatalog) -> PackedStringArray:
	var changed_paths := PackedStringArray()
	for content: ZeliardContent in catalog.all():
		if content is ZeliardAssetDefinition and apply(content as ZeliardAssetDefinition):
			changed_paths.append((content as ZeliardAssetDefinition).source_path)
	changed_paths.sort()
	return changed_paths


static func _diagnostic(asset: ZeliardAssetDefinition, message: String) -> ZeliardDiagnostic:
	return ZeliardDiagnostic.new(
		ZeliardDiagnostic.ERROR,
		&"art.invalid_import",
		asset.content_id,
		asset.resource_path,
		&"source_path",
		message
	)
