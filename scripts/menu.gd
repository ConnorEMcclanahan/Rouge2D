extends Control
# main menu. the background is a live slice of the game world (grass, trees,
# a hopping slime) with a slow camera pan, and the ui sits on top of it.
# the game canvas is 288x162 logical pixels (4x pixel stretch), so everything
# here is laid out for that.

const UiTheme = preload("res://scripts/ui_theme.gd")

var bg_layer: CanvasLayer
var bg: Node2D
var mascot: AnimatedSprite2D
var dim: ColorRect
var vignette: TextureRect
var title_row: HBoxContainer
var subtitle: Label
var center: PanelContainer
var version_label: Label
var title_chars: Array[Label] = []

func _ready() -> void:
	_build_background()

	dim = ColorRect.new()
	dim.color = Color(0.02, 0.04, 0.02, 0.42)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	vignette = UiTheme.make_vignette(0.55)
	add_child(vignette)

	_add_fireflies()
	_build_ui()

	await get_tree().process_frame
	_layout()
	get_viewport().size_changed.connect(_layout)
	_animations()

func _process(_delta: float) -> void:
	# keep the slime pinned to the bottom-left of the screen while the world pans
	if is_instance_valid(mascot):
		mascot.position = Vector2(-bg.position.x + 15.0, -bg.position.y + 144.0)

# ---- the pixel art world behind everything --------------------------------

func _build_background() -> void:
	bg_layer = CanvasLayer.new()
	bg_layer.layer = -1
	add_child(bg_layer)

	bg = Node2D.new()
	bg.y_sort_enabled = true
	bg_layer.add_child(bg)

	# grass field
	var ts := TileSet.new()
	ts.tile_size = Vector2i(16, 16)
	var src := TileSetAtlasSource.new()
	src.texture = load("res://art/mystic_woods_free_2.2/sprites/tilesets/plains.png")
	src.texture_region_size = Vector2i(16, 16)
	var grass: Array[Vector2i] = []
	# speckled grass rows (0-2 full, row 3 has 4 tiles)
	for y in range(3):
		for x in range(6):
			grass.append(Vector2i(x, y))
	for x in range(4):
		grass.append(Vector2i(x, 3))
	# the lush green rows, double-weighted so the field stays green
	for y in range(4, 6):
		for x in range(6):
			grass.append(Vector2i(x, y))
			grass.append(Vector2i(x, y))
	var seen := {}
	for c in grass:
		if seen.has(c):
			continue
		seen[c] = true
		src.create_tile(c)
	ts.add_source(src, 0)
	var ground := TileMapLayer.new()
	ground.tile_set = ts
	bg.add_child(ground)
	for gy in range(-8, 20):
		for gx in range(-28, 28):
			ground.set_cell(Vector2i(gx, gy), 0, grass[(gx * 7 + gy * 13) % grass.size()])

	# sparse single-tile bushes, keeping the center and the mascot strip clear
	var ts2 := TileSet.new()
	ts2.tile_size = Vector2i(16, 16)
	var tsrc := TileSetAtlasSource.new()
	tsrc.texture = load("res://art/mystic_woods_free_2.2/sprites/objects/objects.png")
	tsrc.texture_region_size = Vector2i(16, 16)
	var spots: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(5, 0), Vector2i(10, 0), Vector2i(11, 0)]
	for s in spots:
		tsrc.create_tile(s)
	ts2.add_source(tsrc, 0)
	var trees := TileMapLayer.new()
	trees.tile_set = ts2
	trees.y_sort_enabled = true
	bg.add_child(trees)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	for i in 14:
		var tx := rng.randi_range(-24, 24)
		var ty := rng.randi_range(-6, 14)
		if abs(tx) < 7 and ty > 0 and ty < 11:
			continue
		trees.set_cell(Vector2i(tx, ty), 0, spots[rng.randi_range(0, spots.size() - 1)])

	# slow pan across the field (moves the bg node itself so the ui stays put)
	bg.position = Vector2(-24, -8)
	var pan := create_tween().set_loops()
	pan.tween_property(bg, "position", Vector2(24, 4), 20.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pan.tween_property(bg, "position", Vector2(-24, -8), 20.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# the slime, chilling in the clearing
	mascot = AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	var slime_sheet: Texture2D = load("res://art/mystic_woods_free_2.2/sprites/characters/slime.png")
	for i in 4:
		var at := AtlasTexture.new()
		at.atlas = slime_sheet
		at.region = Rect2(i * 32, 0, 32, 32)
		frames.add_frame("idle", at)
	frames.set_animation_speed("idle", 3.0)
	mascot.sprite_frames = frames
	mascot.play("idle")
	bg.add_child(mascot)
	_hop_loop()

# slime hops every couple seconds
func _hop_loop() -> void:
	await get_tree().create_timer(2.2).timeout
	if not is_instance_valid(mascot):
		return
	var base_y := mascot.position.y
	var t := create_tween()
	t.tween_property(mascot, "position:y", base_y - 12.0, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(mascot, "position:y", base_y, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_callback(_hop_loop)

# ---- the actual menu ui ----------------------------------------------------

func _build_ui() -> void:
	# title, one node per letter so they can bob
	title_row = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 2)
	for i in "ROUGE".length():
		var char_label := UiTheme.make_label("ROUGE"[i], 32, UiTheme.C_GOLD)
		title_row.add_child(char_label)
		title_chars.append(char_label)
	add_child(title_row)

	subtitle = UiTheme.make_label("a tiny woods adventure", 11, UiTheme.C_MUTED)
	add_child(subtitle)

	# the card with the buttons
	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 5)

	var play_btn := UiTheme.make_button("Play", "green", Vector2(200, 24), 12, true, true)
	play_btn.pressed.connect(_on_play_pressed)
	content.add_child(play_btn)

	var quit_btn := UiTheme.make_button("Quit", "brown", Vector2(200, 22), 11, false, true)
	quit_btn.pressed.connect(func() -> void: get_tree().quit())
	content.add_child(quit_btn)

	content.add_child(UiTheme.make_divider(UiTheme.C_PANEL_BORDER_LIGHT))

	center = UiTheme.make_frame(content)
	add_child(center)
	play_btn.grab_focus()

	version_label = UiTheme.make_label("v0.2", 8, Color("6f6b58"), HORIZONTAL_ALIGNMENT_RIGHT)
	add_child(version_label)

func _animations() -> void:
	# per-letter bob
	for i in title_chars.size():
		var t := create_tween().set_loops()
		t.tween_interval(i * 0.18)
		t.tween_property(title_chars[i], "position:y", -2.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(title_chars[i], "position:y", 2.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# title breathes a little
	var breathe := create_tween().set_loops()
	breathe.tween_property(title_row, "modulate:a", 0.85, 0.9).set_trans(Tween.TRANS_SINE)
	breathe.tween_property(title_row, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)

	# card fades in
	center.modulate.a = 0.0
	center.position.y += 8.0
	var intro := create_tween().set_parallel(true)
	intro.tween_property(center, "modulate:a", 1.0, 0.5)
	intro.tween_property(center, "position:y", center.position.y - 8.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _layout() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	dim.size = vp_size
	dim.position = Vector2.ZERO
	vignette.size = vp_size
	vignette.position = Vector2.ZERO
	title_row.reset_size()
	title_row.position = Vector2((vp_size.x - title_row.size.x) * 0.5, 10)
	subtitle.reset_size()
	subtitle.position = Vector2((vp_size.x - subtitle.size.x) * 0.5, 50)
	center.reset_size()
	center.position = Vector2((vp_size.x - center.size.x) * 0.5, 62)
	version_label.reset_size()
	version_label.position = Vector2(vp_size.x - version_label.size.x - 4.0, vp_size.y - version_label.size.y - 4.0)

# fireflies drifting up with a little sway
func _add_fireflies() -> void:
	for i in 12:
		var fly := ColorRect.new()
		fly.color = Color(1.0, 0.85, 0.4, randf_range(0.3, 0.7))
		fly.size = Vector2(2, 2)
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
	tween.tween_property(fly, "position:y", base_y - 50.0, dur).set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(func(phase: float) -> void:
		fly.position.x = base_x + sin(phase * TAU) * 8.0, 0.0, 2.0, dur)
	tween.tween_property(fly, "modulate:a", 0.0, dur * 0.85).set_trans(Tween.TRANS_LINEAR)
	tween.chain().tween_callback(func() -> void:
		fly.position = Vector2(base_x, base_y)
		fly.modulate.a = randf_range(0.3, 0.7)
		_drift_firefly(fly))

func _on_play_pressed() -> void:
	GameState.reset_run()
	Transition.fade_to("res://scenes/world.tscn")
