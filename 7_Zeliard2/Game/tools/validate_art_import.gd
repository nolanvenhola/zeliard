extends SceneTree


func _init() -> void:
	var catalog := ZeliardContentCatalog.load_directory("res://content")
	var diagnostics := ZeliardArtImportPolicy.diagnose_catalog(catalog)
	if diagnostics.is_empty():
		print("PASS: pixel-art import settings validate")
		quit(0)
		return
	for diagnostic: ZeliardDiagnostic in diagnostics:
		printerr(diagnostic.format())
	quit(1)
