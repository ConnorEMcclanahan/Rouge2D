extends CanvasLayer
## Hearts HUD in a small bordered plate. Heart textures come from UiTheme.

const UiTheme = preload("res://scripts/ui_theme.gd")

var hearts: Array[TextureRect] = []
var full_texture: ImageTexture
var empty_texture: ImageTexture
var pending_health: int = 3
var plate: PanelContainer

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
	var style := UiTheme.make_panel_style(Color("10150de6"), UiTheme.C_PANEL_BORDER, 5)
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

## Tiny scale-pop on a newly gained heart.
func _pop_heart(index: int) -> void:
	if index < 0 or index >= hearts.size():
		return
	var heart := hearts[index]
	heart.scale = Vector2(0.5, 0.5)
	heart.modulate.a = 0.4
	var tween := heart.create_tween()
	tween.set_parallel(true)
	tween.tween_property(heart, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(heart, "modulate:a", 1.0, 0.2)
