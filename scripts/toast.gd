class_name Toast
## Small top-center notification that slides in and back out.

const UiTheme = preload("res://scripts/ui_theme.gd")

static func show(text: String, icon_id: String = "chest") -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var layer := CanvasLayer.new()
	layer.layer = 60
	tree.current_scene.add_child(layer)

	var panel := PanelContainer.new()
	var style := UiTheme.make_panel_style(Color("1b1814"), UiTheme.C_SLATE_BORDER, 5)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 7.0
	panel.add_theme_stylebox_override("panel", style)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(UiTheme.make_icon(icon_id, 14))
	row.add_child(UiTheme.make_label(text, 12, UiTheme.C_GOLD))
	panel.add_child(row)
	layer.add_child(panel)

	await tree.process_frame
	panel.reset_size()
	var vp := panel.get_viewport().get_visible_rect().size
	panel.position = Vector2((vp.x - panel.size.x) * 0.5, 8.0)
	panel.modulate.a = 0.0
	panel.position.y -= 12.0
	var intro := panel.create_tween().set_parallel(true)
	intro.tween_property(panel, "modulate:a", 1.0, 0.22)
	intro.tween_property(panel, "position:y", 8.0, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var out := panel.create_tween()
	out.tween_interval(1.2)
	out.set_parallel(true)
	out.tween_property(panel, "modulate:a", 0.0, 0.3)
	out.tween_property(panel, "position:y", -10.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	out.chain().tween_callback(layer.queue_free)
