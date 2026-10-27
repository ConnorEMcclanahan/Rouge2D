extends CanvasLayer
# upgrade picker. pauses the game, cards stagger in and slide/glow on hover

const UiTheme = preload("res://scripts/ui_theme.gd")
const Upgrades = preload("res://scripts/upgrades.gd")
const Toast = preload("res://scripts/toast.gd")

const TITLE_SIZE := 15
const BUTTON_SIZE := Vector2(204, 28)
const SEPARATION := 5

var overlay: ColorRect
var vignette: TextureRect
var center: PanelContainer
var option_buttons: Array[Button] = []
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

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", SEPARATION)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 8)
	header.add_child(UiTheme.make_icon("chest", 14))
	var title := UiTheme.make_label("Choose an Upgrade", TITLE_SIZE, UiTheme.C_GOLD)
	header.add_child(title)
	content.add_child(header)

	content.add_child(UiTheme.make_divider(UiTheme.C_SLATE_BORDER))

	var first: Button = null
	for id in Upgrades.roll_three():
		var def: Dictionary = Upgrades.UPGRADE_DEFS[id]
		var btn := _make_option_button(id, def)
		btn.pressed.connect(_on_pick.bind(id))
		content.add_child(btn)
		option_buttons.append(btn)
		if first == null:
			first = btn

	center = UiTheme.make_frame(content)
	add_child(center)

	await get_tree().process_frame
	_layout()
	get_viewport().size_changed.connect(_layout)
	if first:
		first.grab_focus()

	# Dialog fade + staggered card entrance
	center.modulate.a = 0.0
	center.scale = Vector2(0.95, 0.95)
	center.pivot_offset = center.size * 0.5
	var intro := create_tween().set_parallel(true)
	intro.tween_property(center, "modulate:a", 1.0, 0.2)
	intro.tween_property(center, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_staggered_entrance()

# card button: icon on the left, name + desc column
func _make_option_button(id: String, def: Dictionary) -> Button:
	var btn := UiTheme.make_button("", "green", BUTTON_SIZE, 11, false, true)
	btn.clip_contents = true

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 10)
	btn.add_child(row)

	var icon_holder := CenterContainer.new()
	icon_holder.custom_minimum_size = Vector2(22, 0)
	icon_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_holder.add_child(UiTheme.make_icon(UiTheme.upgrade_icon(id), 14))
	row.add_child(icon_holder)

	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 0)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(UiTheme.make_label(def["name"], 12, UiTheme.C_GOLD, HORIZONTAL_ALIGNMENT_LEFT))
	col.add_child(UiTheme.make_label(def["desc"], 9, UiTheme.C_MUTED, HORIZONTAL_ALIGNMENT_LEFT))
	row.add_child(col)

	# Hover/focus: slide right, glow (stylebox), and a highlight sweep
	btn.mouse_entered.connect(_card_in.bind(btn))
	btn.mouse_exited.connect(_card_out.bind(btn))
	btn.focus_entered.connect(_card_in.bind(btn))
	btn.focus_exited.connect(_card_out.bind(btn))
	return btn

# entrance: cards slide up one after another
func _staggered_entrance() -> void:
	for i in option_buttons.size():
		var btn := option_buttons[i]
		var slot_y := btn.position.y
		btn.position.y += 26.0
		btn.modulate.a = 0.0
		var tween := create_tween()
		tween.tween_interval(0.08 * i)
		tween.set_parallel(true)
		tween.tween_property(btn, "modulate:a", 1.0, 0.28)
		tween.tween_property(btn, "position:y", slot_y, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _card_in(btn: Button) -> void:
	var tween := btn.create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "position:x", 8.0, 0.16)
	_add_sweep(btn)

func _card_out(btn: Button) -> void:
	var tween := btn.create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "position:x", 0.0, 0.16)

# little shine that sweeps across the hovered card
func _add_sweep(btn: Button) -> void:
	var sweep := TextureRect.new()
	sweep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sweep.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sweep.stretch_mode = TextureRect.STRETCH_SCALE
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 0.0))
	gradient.set_color(0.5, Color(1, 1, 1, 0.24))
	gradient.set_color(1, Color(1, 1, 1, 0.0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(1, 0)
	sweep.texture = texture
	sweep.size = Vector2(70, BUTTON_SIZE.y)
	sweep.position = Vector2(-70, 0)
	btn.add_child(sweep)
	var tween := sweep.create_tween()
	tween.tween_property(sweep, "position:x", BUTTON_SIZE.x + 12.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(sweep.queue_free)

func _layout() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	overlay.size = vp_size
	overlay.position = Vector2.ZERO
	vignette.size = vp_size
	vignette.position = Vector2.ZERO
	center.reset_size()
	center.position = (vp_size - center.size) * 0.5
	center.pivot_offset = center.size * 0.5

func _on_pick(id: String) -> void:
	if chosen:
		return
	chosen = true
	GameState.apply_upgrade(id)
	GameState.chest_used = true
	var def: Dictionary = Upgrades.UPGRADE_DEFS[id]
	Toast.show("%s! %s" % [def["name"], def["desc"]], UiTheme.upgrade_icon(id))
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("refresh_from_gamestate"):
		player.refresh_from_gamestate()
	get_tree().paused = false
	queue_free()
