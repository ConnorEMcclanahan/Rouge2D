extends CanvasLayer
## Roguelike upgrade choice panel. Pauses the game while open.
## Sized to fit the 288x162 game viewport: title + 3 compact option buttons.

const UiTheme = preload("res://scripts/ui_theme.gd")
const Upgrades = preload("res://scripts/upgrades.gd")

const TITLE_SIZE := 16
const BUTTON_SIZE := Vector2(230, 34)
const SEPARATION := 6

var overlay: ColorRect
var center: VBoxContainer
var chosen := false

func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.55)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	center = VBoxContainer.new()
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", SEPARATION)
	add_child(center)

	var title := UiTheme.make_label("Choose an Upgrade", TITLE_SIZE, Color(1.0, 0.9, 0.6))
	title.custom_minimum_size = Vector2(BUTTON_SIZE.x, TITLE_SIZE + 4)
	center.add_child(title)

	var first: Button = null
	for id in Upgrades.roll_three():
		var def: Dictionary = Upgrades.UPGRADE_DEFS[id]
		var btn := UiTheme.make_button("%s\n%s" % [def["name"], def["desc"]])
		btn.custom_minimum_size = BUTTON_SIZE
		btn.add_theme_font_size_override("font_size", 12)
		btn.pressed.connect(_on_pick.bind(id))
		center.add_child(btn)
		if first == null:
			first = btn

	_layout()
	get_viewport().size_changed.connect(_layout)
	if first:
		first.grab_focus()

func _layout() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	overlay.size = vp_size
	overlay.position = Vector2.ZERO
	var total_h: float = (TITLE_SIZE + 4) + BUTTON_SIZE.y * 3.0 + SEPARATION * 3.0
	center.size = Vector2(BUTTON_SIZE.x, total_h)
	center.position = Vector2((vp_size.x - center.size.x) * 0.5, (vp_size.y - center.size.y) * 0.5)

func _on_pick(id: String) -> void:
	if chosen:
		return
	chosen = true
	GameState.apply_upgrade(id)
	GameState.chest_used = true
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("refresh_from_gamestate"):
		player.refresh_from_gamestate()
	get_tree().paused = false
	queue_free()

