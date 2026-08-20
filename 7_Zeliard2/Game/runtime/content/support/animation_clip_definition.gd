@tool
class_name ZeliardAnimationClipDefinition
extends Resource

@export var clip_name: StringName = &"idle"
@export_range(0, 9999) var first_frame: int = 0
@export_range(1, 9999) var frame_count: int = 1
@export_range(0.25, 999.0, 0.25) var frame_duration_quanta: float = 1.0
@export var loop: bool = true


func validation_issues(total_frames: int, property_prefix: String) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if clip_name.is_empty():
		issues.append(_issue(property_prefix + ".clip_name", "clip_name is required"))
	if first_frame < 0 or frame_count <= 0 or first_frame + frame_count > total_frames:
		issues.append(_issue(
			property_prefix,
			"clip %s uses frames %d..%d outside the %d-frame sheet" % [
				clip_name, first_frame, first_frame + frame_count - 1, total_frames,
			]
		))
	if frame_duration_quanta <= 0.0 or not is_equal_approx(frame_duration_quanta * 4.0, round(frame_duration_quanta * 4.0)):
		issues.append(_issue(
			property_prefix + ".frame_duration_quanta",
			"frame duration must be a positive quarter-step multiple of the logical art quantum"
		))
	return issues


func _issue(property_path: String, message: String) -> Dictionary:
	return {
		"code": &"art.invalid_clip",
		"property_path": StringName(property_path),
		"message": message,
	}
