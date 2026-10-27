class_name UiTheme
## Shared UI kit: pixel icons, styled panels, buttons, labels, keycaps and
## backgrounds. Everything is built in code so no theme resource file is needed.
## Screens (menu, HUD, upgrade panel, game over) compose these helpers together.

# --- Palette -----------------------------------------------------------------
const C_BG_TOP := Color("1c2a1a")
const C_BG_BOTTOM := Color("050a06")
const C_PANEL_BG := Color("151d12")
const C_PANEL_BG_SOFT := Color("151d12e6")
const C_PANEL_BORDER := Color("8f7438")
const C_PANEL_BORDER_LIGHT := Color("d9b964")
const C_GOLD := Color("ecc96f")
const C_GOLD_DARK := Color("a8822f")
const C_TEXT := Color("f6efdb")
const C_MUTED := Color("b3ae92")
const C_GREEN := Color("558f47")
const C_GREEN_HOVER := Color("6fb85e")
const C_GREEN_BORDER := Color("9bd583")
const C_BROWN := Color("4a3626")
const C_BROWN_HOVER := Color("5d4632")
const C_BROWN_BORDER := Color("8a6d4d")
const C_RED := Color("b04840")
const C_RED_HOVER := Color("c75c52")
const C_RED_BORDER := Color("e08a7e")
const C_SLATE_BG := Color("1b1814")
const C_SLATE_BORDER := Color("73582e")
const C_SLATE_RIM := Color("3a2d1a")

# --- Icon pixel patterns (strings are 11 chars wide) -------------------------
const ICONS := {
	"heart": [
		"01111011110",
		"11111111111",
		"11111111111",
		"11111111111",
		"01111111110",
		"00111111100",
		"00011111000",
		"00001110000",
		"00000100000",
	],
	"sword": [
		"00000110000",
		"00000110000",
		"00000110000",
		"00000110000",
		"00000110000",
		"00001111000",
		"00000110000",
		"00111001110",
		"00011111100",
		"00000110000",
	],
	"bolt": [
		"00000110000",
		"00001100000",
		"00011000000",
		"00110000000",
		"01111110000",
		"00001100000",
		"00011000000",
		"00110000000",
		"01100000000",
	],
	"wing": [
		"00000111111",
		"00001111110",
		"00011111100",
		"00111111000",
		"01111110000",
		"11111100000",
		"01111000000",
		"00110000000",
	],
	"shield": [
		"01111111110",
		"11111111111",
		"11111111111",
		"11111111111",
		"11111111111",
		"01111111110",
		"01111111110",
		"00111111100",
		"00011111000",
		"00001110000",
	],
	"push": [
		"11000000011",
		"11100000111",
		"01110001110",
		"00111011100",
		"00011111000",
		"00001110000",
	],
	"skull": [
		"00111111100",
		"01111111110",
		"11111111111",
		"11101110111",
		"11101110111",
		"11111111111",
		"01101110110",
		"00111111100",
		"00011111000",
	],
	"chest": [
		"00111111100",
		"01111111110",
		"01111111110",
		"01101110110",
		"01101110110",
		"01111111110",
		"01111111110",
		"01111111110",
		"01111111110",
	],
	"clock": [
		"00111111100",
		"01111111110",
		"11111111111",
		"11111011111",
		"11111011111",
		"11111011111",
		"11111000111",
		"11111111111",
		"01111111110",
		"00111111100",
	],
	"diamond": [
		"00000100000",
		"00001110000",
		"00011111000",
		"00111111100",
		"01111111110",
		"00111111100",
		"00011111000",
		"00001110000",
		"00000100000",
	],
}

# Icon id -> [base, highlight, shade, outline, specular]
const ICON_TINTS := {
	"heart": [Color("e03344"), Color("ff8a93"), Color("8c0f1b"), Color("4a060d"), Color("ffeef0")],
	"sword": [Color("cfd6de"), Color("ffffff"), Color("7c858f"), Color("3d434a"), Color("ffffff")],
	"bolt": [Color("e8c56a"), Color("ffefad"), Color("9c7c2a"), Color("574313"), Color("fff8d8")],
	"wing": [Color("8fd0ff"), Color("e6f6ff"), Color("4a8cc0"), Color("24507a"), Color("ffffff")],
	"shield": [Color("7a9ce0"), Color("c4d5ff"), Color("41579a"), Color("1e2c5c"), Color("eef2ff")],
	"push": [Color("c98f4e"), Color("f2c089"), Color("7c4f22"), Color("45290e"), Color("ffe9d0")],
	"skull": [Color("e8e2d0"), Color("ffffff"), Color("8f8977"), Color("4a463a"), Color("ffffff")],
	"chest": [Color("a06c2e"), Color("d9a054"), Color("5e3c14"), Color("33200a"), Color("f2d489")],
	"clock": [Color("e8c56a"), Color("ffefad"), Color("9c7c2a"), Color("574313"), Color("fff8d8")],
	"diamond": [Color("e6d8a8"), Color("fff4d0"), Color("a08a4c"), Color("5a4a20"), Color("ffffff")],
}

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

# --- Pixel image helpers -----------------------------------------------------

## Builds a tinted, outlined pixel icon texture from a 1/0 pattern.
static func make_icon_texture(id: String) -> ImageTexture:
	var pattern: Array = ICONS[id]
	var tint: Array = ICON_TINTS[id]
	var width := String(pattern[0]).length()
	var height := pattern.size()
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	for y in height:
		var row: String = pattern[y]
		for x in width:
			if row[x] != "1":
				continue
			var color: Color = tint[0]
			if x + y <= 4:
				color = tint[1]
			elif x + y >= width + height - 5:
				color = tint[2]
			image.set_pixel(x, y, color)
	image.set_pixel(1, 1, tint[4])
	image.set_pixel(2, 1, tint[4])
	for y in height:
		for x in width:
			if image.get_pixel(x, y).a > 0.0 and _has_empty_neighbor(image, x, y):
				image.set_pixel(x, y, tint[3])
	return ImageTexture.create_from_image(image)

## A TextureRect already set up to show a pixel icon, scaled by `size`.
static func make_icon(id: String, size: float = 22.0) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = make_icon_texture(id)
	rect.custom_minimum_size = Vector2(size, size)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

## Maps an upgrade id to an icon id (used by the upgrade panel).
static func upgrade_icon(id: String) -> String:
	match id:
		"hearty": return "heart"
		"swift": return "wing"
		"sharp": return "sword"
		"quick": return "bolt"
		"heavy": return "push"
		"sturdy": return "shield"
	return "chest"

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

static func make_full_heart_icon(size := Vector2(22, 18)) -> TextureRect:
	var heart := TextureRect.new()
	heart.texture = make_heart_texture(
		Color("d81e2f"), Color("ff7a84"),
		Color("7c0f1b"), Color("3f060c"), Color("fff2f3"))
	heart.custom_minimum_size = size
	heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	heart.stretch_mode = TextureRect.STRETCH_SCALE
	return heart

static func make_empty_heart_icon(size := Vector2(22, 18)) -> TextureRect:
	var heart := TextureRect.new()
	heart.texture = make_heart_texture(
		Color("232529"), Color("3a3d42"),
		Color("121316"), Color("070709"), Color("2e3136"))
	heart.custom_minimum_size = size
	heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	heart.stretch_mode = TextureRect.STRETCH_SCALE
	return heart

# --- Backgrounds -------------------------------------------------------------

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

## Dark, rounded vignette overlay for a moodier frame.
static func make_vignette(strength: float = 0.45) -> TextureRect:
	var rect := TextureRect.new()
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0, 0, 0, 0))
	gradient.set_color(1, Color(0, 0, 0, strength))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.45)
	texture.fill_to = Vector2(1.0, 1.0)
	texture.width = 256
	texture.height = 256
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

# --- Text --------------------------------------------------------------------

static func make_label(text: String, font_size: int, color: Color = C_TEXT, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color("0a0c08"))
	label.add_theme_constant_override("outline_size", max(2, font_size / 8))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.45))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 3)
	return label

# --- Panels ------------------------------------------------------------------

## Flat panel style with border, rounded corners and a soft drop shadow.
static func make_panel_style(bg: Color = C_SLATE_BG, border: Color = C_SLATE_BORDER, radius: int = 6) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(radius)
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 5
	sb.shadow_offset = Vector2(0, 3)
	sb.content_margin_left = 16.0
	sb.content_margin_right = 16.0
	sb.content_margin_top = 12.0
	sb.content_margin_bottom = 14.0
	return sb

## Thin decorative divider line.
static func make_divider(color: Color = C_PANEL_BORDER, height: float = 2.0) -> ColorRect:
	var rect := ColorRect.new()
	rect.color = color
	rect.custom_minimum_size = Vector2(0, height)
	return rect

## Wraps `child` in a framed dialog: dark rim + slate panel + stitched leather
## border. The stitch dashes read as hand-sewn leather around the card.
static func make_frame(child: Control, bg: Color = C_SLATE_BG, border: Color = C_SLATE_BORDER) -> PanelContainer:
	var outer := PanelContainer.new()
	var rim := StyleBoxFlat.new()
	rim.bg_color = C_SLATE_RIM
	rim.set_corner_radius_all(10)
	rim.shadow_color = Color(0, 0, 0, 0.6)
	rim.shadow_size = 8
	rim.shadow_offset = Vector2(0, 4)
	rim.content_margin_left = 3.0
	rim.content_margin_right = 3.0
	rim.content_margin_top = 3.0
	rim.content_margin_bottom = 4.0
	outer.add_theme_stylebox_override("panel", rim)
	var inner := PanelContainer.new()
	inner.add_theme_stylebox_override("panel", make_panel_style(bg, border, 8))
	var stitched := PanelContainer.new()
	var stitch_style := make_stitch_style()
	stitch_style.content_margin_left = 4.0
	stitch_style.content_margin_right = 4.0
	stitch_style.content_margin_top = 4.0
	stitch_style.content_margin_bottom = 5.0
	stitched.add_theme_stylebox_override("panel", stitch_style)
	stitched.add_child(child)
	inner.add_child(stitched)
	outer.add_child(inner)
	return outer

## Stitch-dash border stylebox (transparent center, dashed thread edges).
static func make_stitch_style(stitch_color: Color = Color("c8a65c")) -> StyleBoxTexture:
	var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(3, 21, 6):
		for dx in 3:
			img.set_pixel(x + dx, 1, stitch_color)
			img.set_pixel(x + dx, 22, stitch_color)
	for y in range(3, 21, 6):
		for dy in 3:
			img.set_pixel(1, y + dy, stitch_color)
			img.set_pixel(22, y + dy, stitch_color)
	var sb := StyleBoxTexture.new()
	sb.texture = ImageTexture.create_from_image(img)
	sb.texture_margin_left = 5.0
	sb.texture_margin_right = 5.0
	sb.texture_margin_top = 5.0
	sb.texture_margin_bottom = 5.0
	return sb

## Soft radial light — used for breathing glows behind menu cards.
static func make_radial_light(inner: Color, size := Vector2(420, 320)) -> TextureRect:
	var rect := TextureRect.new()
	var gradient := Gradient.new()
	gradient.set_color(0, inner)
	gradient.set_color(1, Color(inner, 0.0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(0.0, 0.5)
	texture.width = 256
	texture.height = 256
	rect.texture = texture
	rect.custom_minimum_size = size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

## Divider with a small diamond stud in the middle — line · diamond · line.
## Callers can pulse the diamond (child index 1) for a shimmer effect.
static func make_shimmer_divider(color: Color = C_PANEL_BORDER_LIGHT, height: float = 2.0) -> HBoxContainer:
	var box := HBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 5)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var line_l := ColorRect.new()
	line_l.color = Color(color, 0.55)
	line_l.custom_minimum_size = Vector2(0, height)
	line_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(line_l)
	box.add_child(make_icon("diamond", 9.0))
	var line_r := ColorRect.new()
	line_r.color = Color(color, 0.55)
	line_r.custom_minimum_size = Vector2(0, height)
	line_r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(line_r)
	return box

## Small gold knob texture for slider grabbers.
static func make_knob_texture(bright: bool = false) -> ImageTexture:
	var img := Image.create(10, 10, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in 10:
		for x in 10:
			var d := Vector2(x - 4.5, y - 4.5).length()
			if d < 4.2:
				img.set_pixel(x, y, Color("f0d488") if bright else Color("d9b964") if d < 3.0 else Color("8f7438"))
	return ImageTexture.create_from_image(img)

## Themed HSlider with the stone track + gold knob look.
static func make_slider(min_value: float, max_value: float, value: float) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.value = value
	slider.custom_minimum_size = Vector2(120, 18)
	var track := StyleBoxFlat.new()
	track.bg_color = Color("0d110b")
	track.set_corner_radius_all(4)
	track.content_margin_top = 5.0
	track.content_margin_bottom = 5.0
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("8f7438")
	fill.set_corner_radius_all(4)
	fill.content_margin_top = 5.0
	fill.content_margin_bottom = 5.0
	var area := StyleBoxFlat.new()
	area.bg_color = Color(0, 0, 0, 0)
	slider.add_theme_stylebox_override("slider", track)
	slider.add_theme_stylebox_override("grabber_area", area)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill)
	slider.add_theme_icon_override("grabber", make_knob_texture(false))
	slider.add_theme_icon_override("grabber_highlight", make_knob_texture(true))
	slider.add_theme_icon_override("grabber_disabled", make_knob_texture(false))
	return slider

# --- Buttons -----------------------------------------------------------------

const BUTTON_PALETTES := {
	"green": {
		"bg": C_GREEN, "hover": C_GREEN_HOVER, "border": C_GREEN_BORDER,
		"border_hover": Color("b9e8a8"),
	},
	"brown": {
		"bg": C_BROWN, "hover": C_BROWN_HOVER, "border": C_BROWN_BORDER,
		"border_hover": Color("a9895f"),
	},
	"red": {
		"bg": C_RED, "hover": C_RED_HOVER, "border": C_RED_BORDER,
		"border_hover": Color("f0a89f"),
	},
	"gold": {
		"bg": C_GOLD_DARK, "hover": C_GOLD, "border": C_PANEL_BORDER_LIGHT,
		"border_hover": Color("ffe9a8"),
	},
}

## Styled button with hover grow animation and a gold focus ring.
## `chevron` adds a "»" that slides in on hover/focus.
static func make_button(text: String, kind: String = "green", min_size := Vector2(150, 38), font_size := 15, chevron: bool = false) -> Button:
	var pal: Dictionary = BUTTON_PALETTES.get(kind, BUTTON_PALETTES["green"])
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", C_TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", C_GOLD)
	button.add_theme_color_override("font_focus_color", Color.WHITE)

	var normal := make_panel_style(pal["bg"], pal["border"], 6)
	var hover := make_panel_style(pal["hover"], pal["border_hover"], 6)
	hover.shadow_color = Color(pal["border_hover"], 0.6)
	hover.shadow_size = 8
	var pressed := make_panel_style((pal["bg"] as Color).darkened(0.35), (pal["border"] as Color).darkened(0.2), 6)
	pressed.shadow_size = 2
	var focus := make_panel_style(pal["hover"], C_GOLD, 6)
	focus.set_border_width_all(3)
	var disabled := make_panel_style(Color("262a24"), Color("3a3f36"), 6)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_disabled_color", Color("7a7f70"))

	button.pivot_offset = min_size / 2.0
	button.mouse_entered.connect(_grow.bind(button))
	button.mouse_exited.connect(_shrink.bind(button))
	button.focus_entered.connect(_grow.bind(button))
	button.focus_exited.connect(_shrink.bind(button))
	button.button_down.connect(_squash.bind(button))
	button.button_up.connect(_unsquash.bind(button))
	if chevron:
		var arrow := Label.new()
		arrow.text = "»"
		arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		arrow.add_theme_font_size_override("font_size", font_size + 3)
		arrow.add_theme_color_override("font_color", C_GOLD)
		arrow.modulate.a = 0.35
		arrow.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
		arrow.position = Vector2(-14.0, -1.0)
		button.add_child(arrow)
		button.mouse_entered.connect(_chevron.bind(arrow, true))
		button.mouse_exited.connect(_chevron.bind(arrow, false))
		button.focus_entered.connect(_chevron.bind(arrow, true))
		button.focus_exited.connect(_chevron.bind(arrow, false))
	return button

static func _chevron(arrow: Label, on: bool) -> void:
	var tween := arrow.create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(arrow, "modulate:a", 1.0 if on else 0.35, 0.15)
	tween.tween_property(arrow, "position:x", -10.0 if on else -14.0, 0.15)

static func _grow(button: Button) -> void:
	_ui_sound_stub("hover")
	button.scale = Vector2.ONE
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.14)

static func _shrink(button: Button) -> void:
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE, 0.14)

## Press-down squash before the action fires.
static func _squash(button: Button) -> void:
	_ui_sound_stub("press")
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.06)

static func _unsquash(button: Button) -> void:
	var target := Vector2(1.05, 1.05) if button.is_hovered() else Vector2.ONE
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target, 0.12)

## Placeholder for UI sound effects — wire an AudioStreamPlayer here later.
static func _ui_sound_stub(kind: String) -> void:
	pass

# --- Misc widgets ------------------------------------------------------------

## A keycap-style prompt (dark chip with gold border) wrapping a label.
static func make_keycap(text: String, font_size: int = 11) -> PanelContainer:
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("0d110b")
	sb.border_color = Color("8f7438")
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(4)
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 2
	sb.shadow_offset = Vector2(0, 2)
	sb.content_margin_left = 8.0
	sb.content_margin_right = 8.0
	sb.content_margin_top = 3.0
	sb.content_margin_bottom = 4.0
	panel.add_theme_stylebox_override("panel", sb)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", C_GOLD)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 2)
	panel.add_child(label)
	return panel
