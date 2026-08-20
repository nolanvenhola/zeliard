class_name ZeliardSaveStore
extends RefCounted


static func save(path: String, data: ZeliardSaveData) -> Error:
	if data == null or not data.validation_errors().is_empty():
		return ERR_INVALID_DATA
	var absolute_path := ProjectSettings.globalize_path(path)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		return directory_error
	var temporary_path := path + ".tmp"
	var remove_temporary_error := _remove_if_present(temporary_path)
	if remove_temporary_error != OK:
		return remove_temporary_error
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(ZeliardSaveCodec.encode(data))
	file.flush()
	file.close()
	var temporary_decode := _decode_path(temporary_path)
	if not temporary_decode.success:
		return ERR_FILE_CORRUPT
	var backup_path := path + ".backup"
	if FileAccess.file_exists(path):
		var current_decode := _decode_path(path)
		if current_decode.success:
			var remove_backup_error := _remove_if_present(backup_path)
			if remove_backup_error != OK:
				return remove_backup_error
			var backup_error := _rename(path, backup_path)
			if backup_error != OK:
				return backup_error
		else:
			var quarantine_error := _rename(path, _next_corrupt_path(path))
			if quarantine_error != OK:
				return quarantine_error
	var install_error := _rename(temporary_path, path)
	if install_error != OK:
		return install_error
	return OK


static func load(path: String) -> ZeliardSaveLoadResult:
	var result := ZeliardSaveLoadResult.new()
	var primary := _decode_path(path)
	if primary.success:
		_populate_load_result(result, primary, path, false)
		return result
	var backup_path := path + ".backup"
	var backup := _decode_path(backup_path)
	if backup.success:
		_populate_load_result(result, backup, backup_path, true)
		return result
	result.error_message = "primary: %s; backup: %s" % [primary.error_message, backup.error_message]
	return result


static func _decode_path(path: String) -> ZeliardSaveDecodeResult:
	var result := ZeliardSaveDecodeResult.new()
	if not FileAccess.file_exists(path):
		result.error_message = "file does not exist"
		return result
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		result.error_message = "file cannot be opened: %s" % error_string(FileAccess.get_open_error())
		return result
	var text := file.get_as_text()
	file.close()
	return ZeliardSaveCodec.decode(text)


static func _populate_load_result(
	result: ZeliardSaveLoadResult,
	decoded: ZeliardSaveDecodeResult,
	source_path: String,
	recovered_from_backup: bool
) -> void:
	result.success = true
	result.data = decoded.data
	result.migrated_from_version = decoded.migrated_from_version
	result.source_path = source_path
	result.recovered_from_backup = recovered_from_backup


static func _remove_if_present(path: String) -> Error:
	if not FileAccess.file_exists(path):
		return OK
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


static func _rename(from_path: String, to_path: String) -> Error:
	return DirAccess.rename_absolute(
		ProjectSettings.globalize_path(from_path),
		ProjectSettings.globalize_path(to_path)
	)


static func _next_corrupt_path(path: String) -> String:
	var candidate := path + ".corrupt"
	var suffix: int = 1
	while FileAccess.file_exists(candidate):
		candidate = "%s.corrupt.%d" % [path, suffix]
		suffix += 1
	return candidate
