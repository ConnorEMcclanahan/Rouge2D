extends Control
## Start screen for "Rouge".
## Laid out manually against the viewport (anchors are unreliable for scene roots).

const UiTheme = preload("res://scripts/ui_theme.gd")

var bg: TextureRect
var vignette: TextureRect
var center: PanelContainer
var content: VBoxContainer
var title: Label

func _ready() -> void:
	bg = UiTheme.make_gradient_background(UiTheme.C_BG_TOP, UiTheme.C_BG_BOTTOM)
	add_child(bg)

	_add_motes()

	vignette = UiTheme.make_vignette(0.5)
	add_child(vignette)

	center = PanelContainer.new()
	center.add_theme_stylebox_override("panel", UiTheme.make_panel_style(UiTheme.C_PANEL_BG_SOFT, UiTheme.C_PANEL_BORDER, 8))
	add_child(center)

	content = VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 8)
	center.add_child(content)

	# Title row: slime mascot + game name
	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 10)

	var mascot_holder := Control.new()
	mascot_holder.custom_minimum_size = Vector2(44, 44)
	var mascot := TextureRect.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = load("res://art/mystic_woods_free_2.2/sprites/characters/slime.png")
	atlas.region = Rect2(0, 0, 32, 32)
	mascot.texture = atlas
	mascot.custom_minimum_size = Vector2(44, 44)
	mascot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mascot.stretch_mode = TextureRect.STRETCH_SCALE
	mascot_holder.add_child(mascot)
	title_row.add_child(mascot_holder)

	title = UiTheme.make_label("ROUGE", 34, UiTheme.C_GOLD)
	title_row.add_child(title)
	content.add_child(title_row)

	var subtitle := UiTheme.make_label("a tiny woods adventure", 12, UiTheme.C_MUTED)
	content.add_child(subtitle)

	content.add_child(UiTheme.make_divider(UiTheme.C_PANEL_BORDER))

	var hearts_row := HBoxContainer.new()
	hearts_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hearts_row.add_theme_constant_override("separation", 4)
	for i in 3:
		hearts_row.add_child(UiTheme.make_full_heart_icon())
	content.add_child(hearts_row)

	var buttons_row := HBoxContainer.new()
	buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons_row.add_theme_constant_override("separation", 12)

	var play_btn := UiTheme.make_button("Play", "green", Vector2(110, 36), 15)
	play_btn.pressed.connect(_on_play_pressed)
	buttons_row.add_child(play_btn)

	var quit_btn := UiTheme.make_button("Quit", "brown", Vector2(110, 36), 15)
	quit_btn.pressed.connect(func() -> void: get_tree().quit())
	buttons_row.add_child(quit_btn)
	content.add_child(buttons_row)

	var hint := UiTheme.make_label("WASD move  ·  SPACE attack", 10, UiTheme.C_MUTED)
	content.add_child(hint)

	await get_tree().process_frame
	_layout()
	get_viewport().size_changed.connect(_layout)

	play_btn.grab_focus()

	# Breathing title + mascot hop + card fade-in
	var title_tween := create_tween().set_loops()
	title_tween.tween_property(title, "modulate:a", 0.82, 0.9).set_trans(Tween.TRANS_SINE)
	title_tween.tween_property(title, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)

	var mascot_tween := create_tween().set_loops()
	mascot_tween.tween_property(mascot, "position:y", 4.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	mascot_tween.tween_property(mascot, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	center.modulate.a = 0.0
	var intro := create_tween()
	intro.tween_property(center, "modulate:a", 1.0, 0.45)

func _layout() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	bg.size = vp_size
	bg.position = Vector2.ZERO
	vignette.size = vp_size
	vignette.position = Vector2.ZERO
	center.reset_size()
	center.position = (vp_size - center.size) * 0.5

## Small glowing motes drifting upward behind the menu card.
func _add_motes() -> void:
	for i in 10:
		var mote := ColorRect.new()
		mote.color = Color(1.0, 0.9, 0.55, randf_range(0.05, 0.16))
		mote.size = Vector2(3, 3)
		mote.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mote.position = Vector2(randf() * 288.0, randf() * 162.0)
		add_child(mote)
		_drift(mote)

func _drift(mote: ColorRect) -> void:
	var base_y := mote.position.y
	var dur := randf_range(5.0, 9.0)
	var tween := mote.create_tween()
	tween.set_parallel(true)
	tween.tween_property(mote, "position:y", base_y - 46.0, dur).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(mote, "modulate:a", 0.0, dur).set_trans(Tween.TRANS_LINEAR)
	tween.chain().tween_callback(func() -> void:
		mote.position.y = base_y
		mote.modulate.a = 1.0
		_drift(mote))

func _on_play_pressed() -> void:
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/world.tscn")
