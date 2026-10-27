extends Node
## Scene transition singleton: pixel-dissolve reveal between scenes.
## Usage: Transition.fade_to("res://scenes/world.tscn")

const SHADER := preload("res://scripts/dissolve.gdshader")

var busy := false

func fade_to(path: String) -> void:
	if busy:
		return
	busy = true
	var layer := CanvasLayer.new()
	layer.layer = 100
	get_tree().root.add_child.call_deferred(layer)

	var rect := ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	var noise := NoiseTexture2D.new()
	noise.width = 64
	noise.height = 36
	noise.seamless = true
	var fn := FastNoiseLite.new()
	fn.seed = randi()
	fn.frequency = 0.4
	noise.noise = fn
	mat.set_shader_parameter("noise_tex", noise)
	mat.set_shader_parameter("progress", 0.0)
	rect.material = mat
	layer.add_child(rect)

	# Cover the screen, swap the scene underneath, then dissolve away.
	await get_tree().process_frame
	get_tree().change_scene_to_file(path)
	var tween := create_tween()
	tween.tween_interval(0.12)
	tween.tween_property(mat, "shader_parameter/progress", 1.0, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func() -> void:
		layer.queue_free()
		busy = false)
