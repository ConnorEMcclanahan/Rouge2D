extends CanvasLayer
## Game-over overlay shown after the player dies.
## Laid out manually against the viewport (anchors are unreliable).

const UiTheme = preload("res://scripts/ui_theme.gd")

var bg: TextureRect
var center: VBoxContainer

func _ready() -> void:
	layer = 20

	bg = UiTheme.make_gradient_background(Color(0.2, 0.06, 0.06, 0.88), Color(0.06, 0.02, 0.02, 0.88))
	add_child(bg)

	center = VBoxContainer.new()
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 10)
	center.size = Vector2(220, 150)
	add_child(center)

	var title := UiTheme.make_label("You Died", 30, Color(0.95, 0.3, 0.22))
	center.add_child(title)

	var subtitle := UiTheme.make_label("the woods claim another...", 12, Color(0.85, 0.7, 0.65))
	center.add_child(subtitle)

	var hearts_row := HBoxContainer.new()
	hearts_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hearts_row.add_theme_constant_override("separation", 4)
	for i in 3:
		hearts_row.add_child(UiTheme.make_empty_heart_icon())
	center.add_child(hearts_row)

	var buttons_row := HBoxContainer.new()
	buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons_row.add_theme_constant_override("separation", 10)

	var retry_btn := UiTheme.make_button("Try Again")
	retry_btn.pressed.connect(_on_retry)
	buttons_row.add_child(retry_btn)

	var menu_btn := UiTheme.make_button("Menu", Color(0.28, 0.2, 0.17), Color(0.55, 0.42, 0.35), Color(0.42, 0.3, 0.25), Color(0.75, 0.6, 0.5))
	menu_btn.pressed.connect(_on_menu)
	buttons_row.add_child(menu_btn)
	center.add_child(buttons_row)

	_layout()
	get_viewport().size_changed.connect(_layout)

	retry_btn.grab_focus()

func _layout() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	bg.size = vp_size
	bg.position = Vector2.ZERO
	center.position = (vp_size - center.size) * 0.5

func _on_retry() -> void:
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
