extends Node2D
## World scene glue: soft fade-in when the run starts.

func _ready() -> void:
	_fade_in()

func _fade_in() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 40
	add_child(layer)
	var rect := ColorRect.new()
	rect.color = Color(0, 0, 0, 1)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)
	var tween := create_tween()
	tween.tween_property(rect, "color:a", 0.0, 0.4)
	tween.tween_callback(layer.queue_free)
