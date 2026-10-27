extends CanvasLayer
## Roguelike upgrade choice panel. Pauses the game while open.
## A titled card with three icon + text option buttons.

const UiTheme = preload("res://scripts/ui_theme.gd")
const Upgrades = preload("res://scripts/upgrades.gd")

const TITLE_SIZE := 18
const BUTTON_SIZE := Vector2(232, 40)
const SEPARATION := 8

var overlay: ColorRect
var vignette: TextureRect
var center: PanelContainer
var chosen := false

func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	vignette = UiTheme.make_vignette(0.3)
	add_child(vignette)

	center = PanelContainer.new()
	center.add_theme_stylebox_override("panel", UiTheme.make_panel_style(UiTheme.C_PANEL_BG_SOFT, UiTheme.C_PANEL_BORDER_LIGHT, 8))
	add_child(center)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", SEPARATION)
	center.add_child(content)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 8)
	header.add_child(UiTheme.make_icon("chest", 20))
	var title := UiTheme.make_label("Choose an Upgrade", TITLE_SIZE, UiTheme.C_GOLD)
	header.add_child(title)
	content.add_child(header)

	content.add_child(UiTheme.make_divider(UiTheme.C_PANEL_BORDER))

	var first: Button = null
	for id in Upgrades.roll_three():
		var def: Dictionary = Upgrades.UPGRADE_DEFS[id]
		var btn := _make_option_button(id, def)
		btn.pressed.connect(_on_pick.bind(id))
		content.add_child(btn)
		if first == null:
			first = btn

	await get_tree().process_frame
	_layout()
	get_viewport().size_changed.connect(_layout)
	if first:
		first.grab_focus()

	# Pop-in
	center.modulate.a = 0.0
	center.scale = Vector2(0.92, 0.92)
	center.pivot_offset = center.size * 0.5
	var intro := create_tween().set_parallel(true)
	intro.tween_property(center, "modulate:a", 1.0, 0.22)
	intro.tween_property(center, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## Button with an icon on the left and a two-line name/description column.
func _make_option_button(id: String, def: Dictionary) -> Button:
	var btn := UiTheme.make_button("", "green", BUTTON_SIZE, 13)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 10)
	btn.add_child(row)

	var icon_holder := CenterContainer.new()
	icon_holder.custom_minimum_size = Vector2(26, 0)
	icon_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_holder.add_child(UiTheme.make_icon(UiTheme.upgrade_icon(id), 20))
	row.add_child(icon_holder)

	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 0)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(UiTheme.make_label(def["name"], 14, UiTheme.C_GOLD, HORIZONTAL_ALIGNMENT_LEFT))
	col.add_child(UiTheme.make_label(def["desc"], 10, UiTheme.C_MUTED, HORIZONTAL_ALIGNMENT_LEFT))
	row.add_child(col)
	return btn

func _layout() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	overlay.size = vp_size
	overlay.position = Vector2.ZERO
	vignette.size = vp_size
	vignette.position = Vector2.ZERO
	center.reset_size()
	center.position = (vp_size - center.size) * 0.5

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
