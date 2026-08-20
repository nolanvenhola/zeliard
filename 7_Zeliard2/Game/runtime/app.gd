extends Node2D

const LOGICAL_SIZE := Vector2i(320, 200)


func _ready() -> void:
	ZeliardLog.info(&"application_ready", {"logical_size": LOGICAL_SIZE})
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(LOGICAL_SIZE)), Color("101522"))
	draw_rect(Rect2(16, 16, 288, 168), Color("182536"), false, 2.0)
