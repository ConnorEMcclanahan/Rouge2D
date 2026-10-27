extends CanvasLayer
# pause menu: resume/restart/quit + volume sliders + fullscreen toggle

const UiTheme = preload("res://scripts/ui_theme.gd")

var overlay: ColorRect
var center: PanelContainer

func _ready() -> void:
	layer = 25
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.65)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 3)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 6)
	header.add_child(UiTheme.make_icon("diamond", 10))
	header.add_child(UiTheme.make_label("PAUSED", 16, UiTheme.C_GOLD))
	content.add_child(header)

	content.add_child(UiTheme.make_shimmer_divider(UiTheme.C_SLATE_BORDER))

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 8)
	content.add_child(columns)

	var buttons_col := VBoxContainer.new()
	buttons_col.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons_col.add_theme_constant_override("separation", 3)
	columns.add_child(buttons_col)

	var resume_btn := UiTheme.make_button("Resume", "green", Vector2(120, 22), 11, false, true)
	resume_btn.pressed.connect(_resume)
	buttons_col.add_child(resume_btn)

	var restart_btn := UiTheme.make_button("Restart Run", "brown", Vector2(120, 22), 11, false, true)
	restart_btn.pressed.connect(_restart)
	buttons_col.add_child(restart_btn)

	var quit_btn := UiTheme.make_button("Quit to Menu", "red", Vector2(120, 22), 11, false, true)
	quit_btn.pressed.connect(_quit)
	buttons_col.add_child(quit_btn)

	var settings_col := VBoxContainer.new()
	settings_col.alignment = BoxContainer.ALIGNMENT_CENTER
	settings_col.add_theme_constant_override("separation", 4)
	columns.add_child(settings_col)

	var sfx := _make_setting_row("SFX", UiTheme.make_slider(0.0, 100.0, GameState.sfx_volume))
	sfx.slider.value_changed.connect(func(v: float) -> void: GameState.sfx_volume = v)
	settings_col.add_child(sfx.row)

	var music := _make_setting_row("Music", UiTheme.make_slider(0.0, 100.0, GameState.music_volume))
	music.slider.value_changed.connect(func(v: float) -> void: GameState.music_volume = v)
	settings_col.add_child(music.row)

	var hint := UiTheme.make_label("ESC to resume", 9, UiTheme.C_MUTED)
	settings_col.add_child(hint)

	center = UiTheme.make_frame(content)
	add_child(center)

	await get_tree().process_frame
	_layout()
	get_viewport().size_changed.connect(_layout)

	resume_btn.grab_focus()

	center.modulate.a = 0.0
	center.scale = Vector2(0.94, 0.94)
	center.pivot_offset = center.size * 0.5
	var intro := create_tween().set_parallel(true)
	intro.tween_property(center, "modulate:a", 1.0, 0.18)
	intro.tween_property(center, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _make_setting_row(label_text: String, slider: HSlider) -> Dictionary:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var label := UiTheme.make_label(label_text, 11, UiTheme.C_MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	label.custom_minimum_size = Vector2(36, 0)
	row.add_child(label)
	row.add_child(slider)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return {"row": row, "slider": slider}

static func _box_icon(checked: bool) -> ImageTexture:
	var img := Image.create(10, 10, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 10:
		img.set_pixel(i, 0, Color("8f7438"))
		img.set_pixel(i, 9, Color("8f7438"))
		img.set_pixel(0, i, Color("8f7438"))
		img.set_pixel(9, i, Color("8f7438"))
	if checked:
		for p in [Vector2i(2, 4), Vector2i(3, 5), Vector2i(4, 6), Vector2i(5, 5), Vector2i(6, 4), Vector2i(7, 3), Vector2i(6, 3), Vector2i(5, 4)]:
			img.set_pixel(p.x, p.y, Color("ecc96f"))
	return ImageTexture.create_from_image(img)

func _layout() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	overlay.size = vp_size
	overlay.position = Vector2.ZERO
	center.reset_size()
	center.position = (vp_size - center.size) * 0.5
	center.pivot_offset = center.size * 0.5

func _resume() -> void:
	get_tree().paused = false
	queue_free()

func _restart() -> void:
	get_tree().paused = false
	GameState.reset_run()
	Transition.fade_to("res://scenes/world.tscn")

func _quit() -> void:
	get_tree().paused = false
	Transition.fade_to("res://scenes/menu.tscn")

func _on_fullscreen(pressed: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if pressed else DisplayServer.WINDOW_MODE_WINDOWED)
