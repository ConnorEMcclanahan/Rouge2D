class_name UiTheme
## Shared UI helpers: pixel hearts, styled buttons, outlined labels, gradient backgrounds.
## Use via preload() so it works without the global class cache.

const HEART_PATTERN := [
	"01111011110",
	"11111111111",
	"11111111111",
	"11111111111",
	"01111111110",
	"00111111100",
	"00011111000",
	"00001110000",
	"00000100000",
]

static func make_heart_texture(base: Color, highlight: Color, shade: Color, outline: Color, specular: Color) -> ImageTexture:
	var width := HEART_PATTERN[0].length()
	var height := HEART_PATTERN.size()
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)

	for y in height:
		for x in width:
			if HEART_PATTERN[y][x] != "1":
				continue
			var color := base
			if x + y <= 4:
				color = highlight
			elif x + y >= 12:
				color = shade
			image.set_pixel(x, y, color)

	image.set_pixel(2, 1, specular)
	image.set_pixel(3, 1, specular)

	for y in height:
		for x in width:
			if image.get_pixel(x, y).a > 0.0 and _has_empty_neighbor(image, x, y):
				image.set_pixel(x, y, outline)

	return ImageTexture.create_from_image(image)

static func _has_empty_neighbor(image: Image, x: int, y: int) -> bool:
	var offsets: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for offset in offsets:
		var nx := x + offset.x
		var ny := y + offset.y
		if nx < 0 or ny < 0 or nx >= image.get_width() or ny >= image.get_height():
			return true
		if image.get_pixel(nx, ny).a == 0.0:
			return true
	return false

static func make_full_heart_icon() -> TextureRect:
	var heart := TextureRect.new()
	heart.texture = make_heart_texture(
		Color(0.85, 0.1, 0.15), Color(1.0, 0.45, 0.5),
		Color(0.45, 0.02, 0.06), Color(0.28, 0.02, 0.05), Color(1.0, 0.95, 0.95))
	heart.custom_minimum_size = Vector2(22, 18)
	heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	heart.stretch_mode = TextureRect.STRETCH_SCALE
	return heart

static func make_empty_heart_icon() -> TextureRect:
	var heart := TextureRect.new()
	heart.texture = make_heart_texture(
		Color(0.24, 0.24, 0.27), Color(0.38, 0.38, 0.42),
		Color(0.12, 0.12, 0.14), Color(0.07, 0.07, 0.09), Color(0.3, 0.3, 0.34))
	heart.custom_minimum_size = Vector2(22, 18)
	heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	heart.stretch_mode = TextureRect.STRETCH_SCALE
	return heart

static func make_gradient_background(top: Color, bottom: Color) -> TextureRect:
	var rect := TextureRect.new()
	var gradient := Gradient.new()
	gradient.set_color(0, top)
	gradient.set_color(1, bottom)
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	return rect

static func make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03, 0.85))
	label.add_theme_constant_override("outline_size", max(2, font_size / 8))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 3)
	return label

static func make_button(text: String, bg: Color = Color(0.36, 0.55, 0.28), border: Color = Color(0.65, 0.85, 0.5), hover_bg: Color = Color(0.46, 0.68, 0.36), hover_border: Color = Color(0.9, 1.0, 0.75)) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(96, 30)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color(1.0, 1.0, 0.95))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.95, 0.85))
	button.add_theme_color_override("font_focus_color", Color.WHITE)

	var normal := StyleBoxFlat.new()
	normal.bg_color = bg
	normal.border_color = border
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(5)

	var hover := normal.duplicate()
	hover.bg_color = hover_bg
	hover.border_color = hover_border

	var pressed := normal.duplicate()
	pressed.bg_color = bg.darkened(0.4)
	pressed.border_color = border.darkened(0.3)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	return button
