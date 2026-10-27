extends CanvasLayer
## Game-over overlay shown after the player dies.
## Laid out manually against the viewport (anchors are unreliable).

const UiTheme = preload("res://scripts/ui_theme.gd")

var bg: TextureRect
var vignette: TextureRect
var center: PanelContainer

func _ready() -> void:
	layer = 20

	bg = UiTheme.make_gradient_background(Color("2a0e0c"), Color("0a0302"))
	bg.modulate.a = 0.94
	add_child(bg)

	vignette = UiTheme.make_vignette(0.5)
	add_child(vignette)

	center = PanelContainer.new()
	center.add_theme_stylebox_override("panel", UiTheme.make_panel_style(Color("241214e6"), Color("8c443c"), 8))
	add_child(center)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 8)
	center.add_child(content)

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

	content.add_child(UiTheme.make_divider(Color("8c443c")))

	var hearts_row := HBoxContainer.new()
	hearts_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hearts_row.add_theme_constant_override("separation", 4)
	for i in 3:
		hearts_row.add_child(UiTheme.make_empty_heart_icon())
	content.add_child(hearts_row)

	var buttons_row := HBoxContainer.new()
	buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons_row.add_theme_constant_override("separation", 12)

	var retry_btn := UiTheme.make_button("Try Again", "green", Vector2(120, 36), 14)
	retry_btn.pressed.connect(_on_retry)
	buttons_row.add_child(retry_btn)

	var menu_btn := UiTheme.make_button("Menu", "brown", Vector2(120, 36), 14)
	menu_btn.pressed.connect(_on_menu)
	buttons_row.add_child(menu_btn)
	content.add_child(buttons_row)

	await get_tree().process_frame
	_layout()
	get_viewport().size_changed.connect(_layout)

	retry_btn.grab_focus()

	center.modulate.a = 0.0
	var intro := create_tween()
	intro.tween_property(center, "modulate:a", 1.0, 0.35)

func _layout() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	bg.size = vp_size
	bg.position = Vector2.ZERO
	vignette.size = vp_size
	vignette.position = Vector2.ZERO
	center.reset_size()
	center.position = (vp_size - center.size) * 0.5

func _on_retry() -> void:
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
