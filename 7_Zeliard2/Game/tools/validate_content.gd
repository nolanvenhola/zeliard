extends SceneTree


func _init() -> void:
	var catalog := ZeliardContentCatalog.load_directory("res://content")
	var diagnostics := ZeliardContentValidation.validate_directory("res://content")
	if diagnostics.is_empty():
		print("PASS: %d production content resources validate" % catalog.all().size())
		quit(0)
		return
	for line: String in ZeliardContentValidation.format_lines(diagnostics):
		printerr(line)
	quit(1)
