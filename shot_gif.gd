extends Node
## GIF capture harness — one launch, four modes sequentially.
## Saves resized frames (480x270) to docs/gifs/frames/ and a fresh
## static 1152x648 shot per mode to docs/screenshots/.

var mode := ""
var frame_index := 0
var static_index := 0

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var modes: Array[String] = args if args.size() > 0 else ["menu", "world", "upgrade", "gameover"]
	for m in modes:
		mode = m
		await _capture_mode(m)
		await get_tree().create_timer(0.3).timeout
	print("ALL GIF FRAMES DONE")
	get_tree().quit()

func _capture_mode(m: String) -> void:
	frame_index = 0
	static_index = 0
	var sub := SubViewport.new()
	sub.size = Vector2i(1152, 648)
	sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub.disable_3d = true
	add_child(sub)
	await get_tree().process_frame

	var target: Node = null
	match m:
		"menu":
			target = load("res://scenes/menu.tscn").instantiate()
			sub.add_child(target)
		"world":
			target = load("res://scenes/world.tscn").instantiate()
			sub.add_child(target)
			_schedule_world_sim(target)
		"upgrade":
			target = preload("res://scripts/upgrade_panel.gd").new()
			sub.add_child(target)
			_schedule_upgrade_sim(target)
		"gameover":
			target = preload("res://scripts/game_over.gd").new()
			sub.add_child(target)
	await get_tree().process_frame

	# The upgrade panel pauses the tree in its _ready; unpause so its
	# entrance/hover animations play while we capture.
	if m == "upgrade":
		get_tree().paused = false

	for i in 60:
		await get_tree().create_timer(0.09).timeout
		_snap(sub)

	# One full-res static shot for the README gallery
	var big := sub.get_texture().get_image()
	big.save_png("res://docs/screenshots/%s.png" % m)
	sub.queue_free()

func _snap(sub: SubViewport) -> void:
	var img := sub.get_texture().get_image()
	img.resize(480, 270, Image.INTERPOLATE_LANCZOS)
	img.save_png("res://docs/gifs/frames/%s_%03d.png" % [mode, frame_index])
	frame_index += 1

## Simulated interactions for the world GIF.
func _schedule_world_sim(world: Node) -> void:
	# Pan camera toward the boss, engage him, then trade hits.
	await get_tree().create_timer(0.4).timeout
	var player := world.get_node_or_null("Node2D/player") as Node2D
	var bones := world.get_node_or_null("Node2D/bones")
	if player:
		player.global_position = Vector2(-140, -60)
	await get_tree().create_timer(0.9).timeout
	if bones and bones.has_method("_on_detection_area_body_entered") and player:
		bones._on_detection_area_body_entered(player)
	await get_tree().create_timer(0.8).timeout
	if bones and bones.has_method("take_damage"):
		bones.take_damage(1, Vector2.LEFT)
	await get_tree().create_timer(0.7).timeout
	if player and bones and player.has_method("take_damage"):
		player.take_damage(1, bones)
	await get_tree().create_timer(0.7).timeout
	if bones and bones.has_method("take_damage"):
		bones.take_damage(1, Vector2.LEFT)

## Simulated hover/press for the upgrade GIF.
func _schedule_upgrade_sim(panel: Node) -> void:
	await get_tree().create_timer(1.1).timeout
	var buttons: Array = panel.get("option_buttons") if panel else []
	if buttons.size() > 1:
		var card: Button = buttons[1]
		card.mouse_entered.emit()
		await get_tree().create_timer(1.2).timeout
		card.button_down.emit()
		await get_tree().create_timer(0.3).timeout
		card.button_up.emit()
