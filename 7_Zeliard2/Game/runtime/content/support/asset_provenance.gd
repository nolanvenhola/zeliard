@tool
class_name ZeliardAssetProvenance
extends Resource

const SUPPORTED_ORIGINS := [
	"original_in_house",
	"commissioned",
	"third_party",
	"tool_generated",
	"generative_assisted",
]

@export var creator: String = ""
@export var rights_holder: String = ""
@export_enum("original_in_house", "commissioned", "third_party", "tool_generated", "generative_assisted")
var origin: String = "original_in_house"
@export var source_record: String = ""
@export var license_name: String = ""
@export var attribution: String = ""
@export var modification_permitted: bool = false
@export var commercial_distribution_permitted: bool = false
@export var tools_and_versions: String = ""
@export var creation_date: String = ""
@export var reviewed: bool = false
@export var placeholder: bool = true


func validation_issues() -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	_append_required(issues, &"creator", creator)
	_append_required(issues, &"rights_holder", rights_holder)
	_append_required(issues, &"source_record", source_record)
	_append_required(issues, &"license_name", license_name)
	_append_required(issues, &"tools_and_versions", tools_and_versions)
	if not SUPPORTED_ORIGINS.has(origin):
		issues.append(_issue(&"asset.invalid_provenance", &"provenance.origin", "unsupported provenance origin %s" % origin))
	if not _valid_date(creation_date):
		issues.append(_issue(&"asset.invalid_provenance", &"provenance.creation_date", "creation_date must use YYYY-MM-DD"))
	return issues


func _append_required(issues: Array[Dictionary], property_path: StringName, value: String) -> void:
	if value.strip_edges().is_empty():
		issues.append(_issue(
			&"asset.missing_provenance",
			StringName("provenance.%s" % property_path),
			"%s is required" % property_path
		))


func _valid_date(value: String) -> bool:
	var expression := RegEx.new()
	return expression.compile("^[0-9]{4}-[0-9]{2}-[0-9]{2}$") == OK and expression.search(value) != null


func _issue(code: StringName, property_path: StringName, message: String) -> Dictionary:
	return {"code": code, "property_path": property_path, "message": message}
