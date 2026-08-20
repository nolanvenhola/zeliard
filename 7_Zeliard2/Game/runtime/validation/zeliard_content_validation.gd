class_name ZeliardContentValidation
extends RefCounted


static func validate_directory(root: String) -> Array[ZeliardDiagnostic]:
	var catalog := ZeliardContentCatalog.load_directory(root)
	return ZeliardContentValidator.diagnose_graph(catalog.all())


static func format_lines(diagnostics: Array[ZeliardDiagnostic]) -> PackedStringArray:
	var lines := PackedStringArray()
	for diagnostic: ZeliardDiagnostic in diagnostics:
		lines.append(diagnostic.format())
	return lines
