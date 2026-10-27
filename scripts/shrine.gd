extends Area2D
# chest shrine. space to open, gives an upgrade. builds its own sprite and
# collision if the scene doesn't have them

const CHEST_TEXTURE = preload("res://art/mystic_woods_free_2.2/sprites/objects/chest_01.png")

var sprite: AnimatedSprite2D
var is_opening := false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  # the player
	monitoring = true
	if not has_node("CollisionShape2D"):
		_build_shape()
	if not has_node("AnimatedSprite2D"):
		_build_sprite()
	sprite = $AnimatedSprite2D
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if GameState.chest_used:
		sprite.play("open")
		sprite.frame = 3
	else:
		sprite.play("closed")

func _build_shape() -> void:
	var shape_node := CollisionShape2D.new()
	shape_node.name = "CollisionShape2D"
	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 20)
	shape_node.shape = rect
	add_child(shape_node)

func _build_sprite() -> void:
	var frames := SpriteFrames.new()
	frames.add_animation("closed")
	frames.add_animation("open")
	frames.set_animation_speed("open", 5.0)
	frames.set_animation_loop("open", false)
	var closed := AtlasTexture.new()
	closed.atlas = CHEST_TEXTURE
	closed.region = Rect2(0, 0, 16, 16)
	frames.add_frame("closed", closed)
	for i in 4:
		var frame := AtlasTexture.new()
		frame.atlas = CHEST_TEXTURE
		frame.region = Rect2(i * 16, 0, 16, 16)
		frames.add_frame("open", frame)
	var built := AnimatedSprite2D.new()
	built.name = "AnimatedSprite2D"
	built.sprite_frames = frames
	built.scale = Vector2(2, 2)
	add_child(built)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("clear_nearby_interactable"):
		body.clear_nearby_interactable(self)

func interact() -> void:
	if is_opening or GameState.chest_used:
		return
	is_opening = true
	sprite.play("open")
	var panel = preload("res://scripts/upgrade_panel.gd").new()
	panel.name = "UpgradePanel"
	get_tree().current_scene.add_child(panel)

