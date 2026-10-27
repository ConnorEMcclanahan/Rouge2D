extends Control
## Start screen for "Rouge".
## Laid out manually against the viewport (anchors are unreliable for scene roots).

const UiTheme = preload("res://scripts/ui_theme.gd")

var bg: TextureRect
var center: VBoxContainer

func _ready() -> void:
	bg = UiTheme.make_gradient_background(Color(0.15, 0.22, 0.14), Color(0.07, 0.1, 0.07))
	add_child(bg)

	center = VBoxContainer.new()
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 10)
	center.size = Vector2(220, 150)
	add_child(center)

	# Title row: slime mascot + game name
	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 8)

	var mascot_holder := Control.new()
	mascot_holder.custom_minimum_size = Vector2(36, 40)
	var mascot := TextureRect.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = load("res://art/mystic_woods_free_2.2/sprites/characters/slime.png")
	atlas.region = Rect2(0, 0, 32, 32)
	mascot.texture = atlas
	mascot.custom_minimum_size = Vector2(36, 36)
	mascot.size = Vector2(36, 36)
	mascot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mascot.stretch_mode = TextureRect.STRETCH_SCALE
	mascot_holder.add_child(mascot)
	title_row.add_child(mascot_holder)

	var title := UiTheme.make_label("Rouge", 34, Color(1.0, 0.95, 0.72))
	title_row.add_child(title)
	center.add_child(title_row)

	var subtitle := UiTheme.make_label("a tiny woods adventure", 12, Color(0.85, 0.88, 0.8))
	center.add_child(subtitle)

	var hearts_row := HBoxContainer.new()
	hearts_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hearts_row.add_theme_constant_override("separation", 4)
	for i in 3:
		hearts_row.add_child(UiTheme.make_full_heart_icon())
	center.add_child(hearts_row)

	var buttons_row := HBoxContainer.new()
	buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons_row.add_theme_constant_override("separation", 10)

	var play_btn := UiTheme.make_button("Play")
	play_btn.pressed.connect(_on_play_pressed)
	buttons_row.add_child(play_btn)

	var quit_btn := UiTheme.make_button("Quit", Color(0.28, 0.2, 0.17), Color(0.55, 0.42, 0.35), Color(0.42, 0.3, 0.25), Color(0.75, 0.6, 0.5))
	quit_btn.pressed.connect(func() -> void: get_tree().quit())
	buttons_row.add_child(quit_btn)
	center.add_child(buttons_row)

	_layout()
	get_viewport().size_changed.connect(_layout)

	play_btn.grab_focus()

	# Gentle breathing on the title + mascot hop
	var title_tween := create_tween().set_loops()
	title_tween.tween_property(title, "modulate:a", 0.85, 0.9).set_trans(Tween.TRANS_SINE)
	title_tween.tween_property(title, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)

	var mascot_tween := create_tween().set_loops()
	mascot_tween.tween_property(mascot, "position:y", 3.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	mascot_tween.tween_property(mascot, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _layout() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	bg.size = vp_size
	bg.position = Vector2.ZERO
	center.position = (vp_size - center.size) * 0.5

func _on_play_pressed() -> void:
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/world.tscn")


