class_name ZeliardSaveLoadResult
extends RefCounted

var success: bool = false
var data: ZeliardSaveData
var recovered_from_backup: bool = false
var source_path: String = ""
var migrated_from_version: int = 0
var error_message: String = ""
