extends Control
## Start screen for "Rouge".
## Laid out manually against the viewport (anchors are unreliable for scene roots).

const UiTheme = preload("res://scripts/ui_theme.gd")

var bg: TextureRect
var light: TextureRect
var vignette: TextureRect
var center: PanelContainer
var content: VBoxContainer
var title: Label

func _ready() -> void:
	bg = UiTheme.make_gradient_background(Color("1d2b1c"), Color("050a06"))
	add_child(bg)

	_add_fireflies()

	# Breathing radial glow behind the card
	light = UiTheme.make_radial_light(Color(0.55, 0.48, 0.28, 0.16), Vector2(460, 360))
	add_child(light)

	vignette = UiTheme.make_vignette(0.55)
	add_child(vignette)

	content = VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 8)

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

	content.add_child(UiTheme.make_divider(UiTheme.C_SLATE_BORDER))

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

	center = UiTheme.make_frame(content)
	add_child(center)

	await get_tree().process_frame
	_layout()
	get_viewport().size_changed.connect(_layout)

	play_btn.grab_focus()

	# Breathing title + mascot hop + slow light pulse + card fade-in
	var title_tween := create_tween().set_loops()
	title_tween.tween_property(title, "modulate:a", 0.82, 0.9).set_trans(Tween.TRANS_SINE)
	title_tween.tween_property(title, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)

	var mascot_tween := create_tween().set_loops()
	mascot_tween.tween_property(mascot, "position:y", 4.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	mascot_tween.tween_property(mascot, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	var light_tween := create_tween().set_loops()
	light_tween.tween_property(light, "modulate:a", 1.0, 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	light_tween.tween_property(light, "modulate:a", 0.55, 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var light_scale := create_tween().set_loops()
	light_scale.tween_property(light, "scale", Vector2(1.12, 1.12), 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	light_scale.tween_property(light, "scale", Vector2.ONE, 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	center.modulate.a = 0.0
	center.position.y += 10.0
	var intro := create_tween().set_parallel(true)
	intro.tween_property(center, "modulate:a", 1.0, 0.5)
	intro.tween_property(center, "position:y", center.position.y - 10.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _layout() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	bg.size = vp_size
	bg.position = Vector2.ZERO
	vignette.size = vp_size
	vignette.position = Vector2.ZERO
	center.reset_size()
	center.position = (vp_size - center.size) * 0.5
	light.position = (vp_size - light.size) * 0.5 + Vector2(0, -10)

## Fireflies: glowing dots drifting upward with a side-to-side sway.
func _add_fireflies() -> void:
	for i in 14:
		var fly := ColorRect.new()
		fly.color = Color(1.0, 0.85, 0.4, randf_range(0.25, 0.6))
		fly.size = Vector2(3, 3)
		fly.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fly.position = Vector2(randf() * 288.0, randf() * 162.0)
		add_child(fly)
		_drift_firefly(fly)

func _drift_firefly(fly: ColorRect) -> void:
	var base_x := fly.position.x
	var base_y := fly.position.y
	var dur := randf_range(6.0, 11.0)
	var tween := fly.create_tween()
	tween.set_parallel(true)
	tween.tween_property(fly, "position:y", base_y - 55.0, dur).set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(func(phase: float) -> void:
		fly.position.x = base_x + sin(phase * TAU) * 10.0, 0.0, 2.0, dur)
	tween.tween_property(fly, "modulate:a", 0.0, dur * 0.85).set_trans(Tween.TRANS_LINEAR)
	tween.chain().tween_callback(func() -> void:
		fly.position = Vector2(base_x, base_y)
		fly.modulate.a = randf_range(0.25, 0.6)
		_drift_firefly(fly))

func _on_play_pressed() -> void:
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/world.tscn")
