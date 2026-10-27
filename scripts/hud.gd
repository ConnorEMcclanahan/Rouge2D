extends CanvasLayer
## Hearts HUD in a stone/leather plate. Hearts shake and flash on damage,
## pulse when healing.

const UiTheme = preload("res://scripts/ui_theme.gd")

var hearts: Array[TextureRect] = []
var full_texture: ImageTexture
var empty_texture: ImageTexture
var pending_health: int = 3
var plate: PanelContainer
var stats_plate: PanelContainer
var time_label: Label
var kills_label: Label
var low_pulse_tween: Tween
var is_low_pulsing := false

func _ready() -> void:
	layer = 10
	full_texture = UiTheme.make_heart_texture(
		Color("d81e2f"), Color("ff7a84"),
		Color("7c0f1b"), Color("3f060c"), Color("fff2f3")
	)
	empty_texture = UiTheme.make_heart_texture(
		Color("232529"), Color("3a3d42"),
		Color("121316"), Color("070709"), Color("2e3136")
	)

	plate = PanelContainer.new()
	plate.name = "Plate"
	var style := UiTheme.make_panel_style(Color("241d14"), UiTheme.C_SLATE_BORDER, 5)
	style.shadow_size = 2
	style.shadow_offset = Vector2(0, 2)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 5.0
	style.content_margin_bottom = 6.0
	plate.add_theme_stylebox_override("panel", style)
	plate.position = Vector2(6, 6)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(plate)

	var container := HBoxContainer.new()
	container.name = "Hearts"
	container.add_theme_constant_override("separation", 3)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(container)

	for i in 3:
		_append_heart(container)

	await get_tree().process_frame
	plate.reset_size()
	_build_stats()
	_update_stats_pos()
	get_viewport().size_changed.connect(_update_stats_pos)
	set_health(pending_health)

func _append_heart(container: HBoxContainer) -> void:
	var heart := TextureRect.new()
	heart.custom_minimum_size = Vector2(22, 18)
	heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	heart.stretch_mode = TextureRect.STRETCH_SCALE
	heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(heart)
	hearts.append(heart)

func set_max_health(max_health: int) -> void:
	var container := get_node("Plate/Hearts") as HBoxContainer
	while hearts.size() < max_health:
		_append_heart(container)
	while hearts.size() > max_health:
		var heart: TextureRect = hearts.pop_back()
		heart.queue_free()
	plate.reset_size()
	set_health(pending_health)

func set_health(current: int) -> void:
	var gained := current > pending_health
	pending_health = current
	if hearts.is_empty():
		return
	for i in hearts.size():
		hearts[i].texture = full_texture if i < current else empty_texture
	if gained:
		_pop_heart(current - 1)
	if current <= 1 and not is_low_pulsing:
		_start_low_pulse()
	elif current > 1 and is_low_pulsing:
		_stop_low_pulse()

## Top-right run tracker: elapsed time + kill count.
func _build_stats() -> void:
	stats_plate = PanelContainer.new()
	stats_plate.name = "StatsPlate"
	var style := UiTheme.make_panel_style(Color("241d14"), UiTheme.C_SLATE_BORDER, 5)
	style.shadow_size = 2
	style.shadow_offset = Vector2(0, 2)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 5.0
	stats_plate.add_theme_stylebox_override("panel", style)
	stats_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stats_plate)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stats_plate.add_child(row)

	row.add_child(UiTheme.make_icon("clock", 12))
	time_label = UiTheme.make_label("0:00", 10, UiTheme.C_TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	row.add_child(time_label)

	var sep := ColorRect.new()
	sep.color = Color(UiTheme.C_SLATE_BORDER, 0.5)
	sep.custom_minimum_size = Vector2(1, 10)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(sep)

	row.add_child(UiTheme.make_icon("skull", 12))
	kills_label = UiTheme.make_label("0", 10, UiTheme.C_TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	row.add_child(kills_label)

func _update_stats_pos() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	stats_plate.reset_size()
	stats_plate.position = Vector2(vp_size.x - stats_plate.size.x - 6.0, 6.0)

func _process(delta: float) -> void:
	if time_label == null or kills_label == null:
		return
	GameState.run_elapsed += delta
	var total := int(GameState.run_elapsed)
	time_label.text = "%d:%02d" % [total / 60, total % 60]
	kills_label.text = str(GameState.kills)

## Low-health warning: hearts pulse red until healed above 1.
func _start_low_pulse() -> void:
	is_low_pulsing = true
	var container := get_node("Plate/Hearts") as Control
	container.modulate = Color.WHITE
	low_pulse_tween = container.create_tween().set_loops()
	low_pulse_tween.tween_property(container, "modulate", Color(1.0, 0.45, 0.45), 0.45).set_trans(Tween.TRANS_SINE)
	low_pulse_tween.tween_property(container, "modulate", Color.WHITE, 0.45).set_trans(Tween.TRANS_SINE)

func _stop_low_pulse() -> void:
	is_low_pulsing = false
	if low_pulse_tween and low_pulse_tween.is_valid():
		low_pulse_tween.kill()
	get_node("Plate/Hearts").modulate = Color.WHITE

## Damage feedback: hearts flash red while the plate shakes horizontally.
func shake() -> void:
	var base := plate.position
	for heart in hearts:
		heart.modulate = Color(2.5, 0.45, 0.45)
	var tween := plate.create_tween()
	for i in 6:
		var offset := 3.0 if i % 2 == 0 else -3.0
		tween.tween_property(plate, "position:x", base.x + offset, 0.045)
	tween.tween_property(plate, "position", base, 0.05)
	for heart in hearts:
		var restore := heart.create_tween()
		restore.tween_property(heart, "modulate", Color.WHITE, 0.35)

## Heal feedback: scale bounce 1.3 -> 1.0.
func _pop_heart(index: int) -> void:
	if index < 0 or index >= hearts.size():
		return
	var heart := hearts[index]
	heart.scale = Vector2(1.3, 1.3)
	heart.modulate.a = 0.5
	var tween := heart.create_tween()
	tween.set_parallel(true)
	tween.tween_property(heart, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(heart, "modulate:a", 1.0, 0.25)
