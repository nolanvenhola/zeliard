extends SceneTree

const OUTPUT_PATH := "res://content/example/assets/hero_placeholder.png"


func _init() -> void:
	var image := Image.create_empty(16, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_rect(image, Rect2i(5, 1, 6, 6), Color("f4e8c1"))
	_draw_rect(image, Rect2i(3, 7, 10, 10), Color("67cbe4"))
	_draw_rect(image, Rect2i(2, 17, 5, 7), Color("30324a"))
	_draw_rect(image, Rect2i(9, 17, 5, 7), Color("30324a"))
	_draw_rect(image, Rect2i(13, 8, 3, 9), Color("e6b94a"))
	var error := image.save_png(OUTPUT_PATH)
	print("PASS: generated %s" % OUTPUT_PATH if error == OK else "FAIL: could not generate fixture (%d)" % error)
	quit(error)


func _draw_rect(image: Image, rectangle: Rect2i, color: Color) -> void:
	for y: int in range(rectangle.position.y, rectangle.end.y):
		for x: int in range(rectangle.position.x, rectangle.end.x):
			image.set_pixel(x, y, color)
