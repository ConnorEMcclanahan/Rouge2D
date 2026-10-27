extends CanvasLayer
# you died screen — crimson wash, then the dialog pops in

const UiTheme = preload("res://scripts/ui_theme.gd")

var bg: TextureRect
var flash: ColorRect
var vignette: TextureRect
var center: PanelContainer

func _ready() -> void:
	layer = 20

	bg = UiTheme.make_gradient_background(Color("200807"), Color("070202"))
	add_child(bg)

	# crimson wash over the whole screen
	flash = ColorRect.new()
	flash.color = Color(0.16, 0.02, 0.03, 0.0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)

	vignette = UiTheme.make_vignette(0.5)
	add_child(vignette)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 8)

	# Skull icon + title
	var skull_row := HBoxContainer.new()
	skull_row.alignment = BoxContainer.ALIGNMENT_CENTER
	skull_row.add_theme_constant_override("separation", 8)
	skull_row.add_child(UiTheme.make_icon("skull", 24))
	var title := UiTheme.make_label("You Died", 30, Color("e5736a"))
	skull_row.add_child(title)
	content.add_child(skull_row)

	var subtitle := UiTheme.make_label("the woods claim another...", 12, Color("c99a92"))
	content.add_child(subtitle)

	var divider := UiTheme.make_shimmer_divider(Color("a86a55"))
	content.add_child(divider)
	var diamond: Control = divider.get_child(1)
	var diamond_tween := create_tween().set_loops()
	diamond_tween.tween_property(diamond, "modulate:a", 1.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	diamond_tween.tween_property(diamond, "modulate:a", 0.35, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var hearts_row := HBoxContainer.new()
	hearts_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hearts_row.add_theme_constant_override("separation", 4)
	for i in 3:
		hearts_row.add_child(UiTheme.make_empty_heart_icon())
	content.add_child(hearts_row)

	var buttons_row := HBoxContainer.new()
	buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons_row.add_theme_constant_override("separation", 12)

	var retry_btn := UiTheme.make_button("Try Again", "green", Vector2(120, 36), 14, true)
	retry_btn.pressed.connect(_on_retry)
	buttons_row.add_child(retry_btn)

	var menu_btn := UiTheme.make_button("Menu", "brown", Vector2(120, 36), 14)
	menu_btn.pressed.connect(_on_menu)
	buttons_row.add_child(menu_btn)
	content.add_child(buttons_row)

	center = UiTheme.make_frame(content, Color("201213"), Color("8c443c"))
	add_child(center)

	await get_tree().process_frame
	_layout()
	get_viewport().size_changed.connect(_layout)

	retry_btn.grab_focus()

	# Crimson wash first, then the dialog scales up with an elastic pop
	var wash := create_tween()
	wash.tween_property(flash, "color:a", 0.85, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	wash.tween_property(flash, "color:a", 0.55, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	center.modulate.a = 0.0
	center.scale = Vector2(0.8, 0.8)
	center.pivot_offset = center.size * 0.5
	var intro := create_tween().set_parallel(true)
	intro.tween_property(center, "modulate:a", 1.0, 0.25)
	intro.tween_property(center, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _layout() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	bg.size = vp_size
	bg.position = Vector2.ZERO
	flash.size = vp_size
	flash.position = Vector2.ZERO
	vignette.size = vp_size
	vignette.position = Vector2.ZERO
	center.reset_size()
	center.position = (vp_size - center.size) * 0.5
	center.pivot_offset = center.size * 0.5

func _on_retry() -> void:
	GameState.reset_run()
	Transition.fade_to("res://scenes/world.tscn")

func _on_menu() -> void:
	Transition.fade_to("res://scenes/menu.tscn")
