class_name CombatText
## Floating combat numbers that pop off damaged characters.

static func spawn(parent: Node, pos: Vector2, text: String, color: Color = Color("ffd98a"), size := 13) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos + Vector2(-8, -48)
	label.z_index = 50
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.02, 0.9))
	label.add_theme_constant_override("outline_size", 3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	label.scale = Vector2(0.6, 0.6)
	var drift := Vector2(randf_range(-7.0, 7.0), -24.0)
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position", label.position + drift, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)
	return label
