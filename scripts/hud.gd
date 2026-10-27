extends CanvasLayer
## Zelda-style hearts HUD. Heart textures come from the shared UiTheme helpers.
const UiTheme = preload("res://scripts/ui_theme.gd")

var hearts: Array[TextureRect] = []
var full_texture: ImageTexture
var empty_texture: ImageTexture
var pending_health: int = 3

func _ready() -> void:
	layer = 10
	full_texture = UiTheme.make_heart_texture(
		Color(0.85, 0.1, 0.15), Color(1.0, 0.45, 0.5),
		Color(0.45, 0.02, 0.06), Color(0.28, 0.02, 0.05), Color(1.0, 0.95, 0.95)
	)
	empty_texture = UiTheme.make_heart_texture(
		Color(0.24, 0.24, 0.27), Color(0.38, 0.38, 0.42),
		Color(0.12, 0.12, 0.14), Color(0.07, 0.07, 0.09), Color(0.3, 0.3, 0.34)
	)

	var container := HBoxContainer.new()
	container.name = "Hearts"
	container.position = Vector2(8, 8)
	container.add_theme_constant_override("separation", 3)
	add_child(container)

	for i in 3:
		var heart := TextureRect.new()
		heart.custom_minimum_size = Vector2(22, 18)
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_SCALE
		container.add_child(heart)
		hearts.append(heart)

	set_health(pending_health)

func set_max_health(max_health: int) -> void:
	var container := get_node("Hearts")
	while hearts.size() < max_health:
		var heart := TextureRect.new()
		heart.custom_minimum_size = Vector2(22, 18)
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_SCALE
		container.add_child(heart)
		hearts.append(heart)
	while hearts.size() > max_health:
		var heart: TextureRect = hearts.pop_back()
		heart.queue_free()
	set_health(pending_health)

func set_health(current: int) -> void:
	pending_health = current
	if hearts.is_empty():
		return
	for i in hearts.size():
		hearts[i].texture = full_texture if i < current else empty_texture

