extends CharacterBody2D
## Skeleton miniboss: 4 hearts, chases the player, lunges up close, hits hard.
## All children (sprite, collision, detection) are built in code.

@export var speed: float = 60.0
@export var health: int = MAX_HEALTH

const UiTheme = preload("res://scripts/ui_theme.gd")
const MAX_HEALTH := 4
const CELL := 48
const LUNGE_RANGE := 56.0
const LUNGE_SPEED := 115.0

var player_chase: bool = false
var player: Node2D = null
var is_dead: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var stun_time: float = 0.0
var lunge_time: float = 0.0

var animated_sprite: AnimatedSprite2D
var detection_area: Area2D
var full_heart_tex: ImageTexture
var empty_heart_tex: ImageTexture
var hearts: Array[TextureRect] = []

func _ready() -> void:
	add_to_group("enemies")
	_build_animated_sprite()
	_build_collision()
	_build_detection_area()
	_build_hearts()

func _build_animated_sprite() -> void:
	animated_sprite = AnimatedSprite2D.new()
	animated_sprite.name = "AnimatedSprite2D"
	animated_sprite.offset = Vector2(0, -16)
	add_child(animated_sprite)

	var atlas: Texture2D = load("res://art/mystic_woods_free_2.2/sprites/characters/skeleton.png")
	var frames := SpriteFrames.new()
	# Rows on the 48x48 sheet (6 frames each):
	# 0-2 idle (down/side/back), 3-5 move, 6-8 attack, 9-11 damaged, 12 death
	_add_row(frames, atlas, "idle", 0)
	_add_row(frames, atlas, "idle_side", 1)
	_add_row(frames, atlas, "idle_back", 2)
	_add_row(frames, atlas, "walk_forward", 3)
	_add_row(frames, atlas, "walk_side", 4)
	_add_row(frames, atlas, "walk_back", 5)
	_add_row(frames, atlas, "attack_forward", 6)
	_add_row(frames, atlas, "attack_side", 7)
	_add_row(frames, atlas, "attack_back", 8)
	_add_row(frames, atlas, "hit", 9)
	_add_row(frames, atlas, "death", 12)
	animated_sprite.sprite_frames = frames
	animated_sprite.play("idle")

func _add_row(frames: SpriteFrames, atlas: Texture2D, anim_name: String, row: int) -> void:
	frames.add_animation(anim_name)
	frames.set_animation_speed(anim_name, 6.0)
	frames.set_animation_loop(anim_name, true)
	for i in 6:
		var cell := AtlasTexture.new()
		cell.atlas = atlas
		cell.region = Rect2(i * CELL, row * CELL, CELL, CELL)
		frames.add_frame(anim_name, cell)

func _build_collision() -> void:
	var shape_node := CollisionShape2D.new()
	shape_node.position = Vector2(0, -2)
	var circle := CircleShape2D.new()
	circle.radius = 13.0
	shape_node.shape = circle
	add_child(shape_node)

func _build_detection_area() -> void:
	detection_area = Area2D.new()
	detection_area.name = "detection_area"
	detection_area.position = Vector2(0, -2)
	detection_area.collision_layer = 2
	detection_area.collision_mask = 2
	var shape_node := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 120.0
	shape_node.shape = circle
	detection_area.add_child(shape_node)
	add_child(detection_area)
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

# Hearts above the miniboss: everything in this game is hearts, no bars
func _build_hearts() -> void:
	full_heart_tex = UiTheme.make_heart_texture(
		Color(0.85, 0.1, 0.15), Color(1.0, 0.45, 0.5),
		Color(0.45, 0.02, 0.06), Color(0.28, 0.02, 0.05), Color(1.0, 0.95, 0.95))
	empty_heart_tex = UiTheme.make_heart_texture(
		Color(0.24, 0.24, 0.27), Color(0.38, 0.38, 0.42),
		Color(0.12, 0.12, 0.14), Color(0.07, 0.07, 0.09), Color(0.3, 0.3, 0.34))
	for i in MAX_HEALTH:
		var heart := TextureRect.new()
		heart.texture = full_heart_tex
		heart.custom_minimum_size = Vector2(11, 9)
		heart.size = Vector2(11, 9)
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_SCALE
		heart.position = Vector2(-26 + i * 13, -44)
		add_child(heart)
		hearts.append(heart)

func _update_hearts() -> void:
	for i in hearts.size():
		hearts[i].texture = full_heart_tex if i < health else empty_heart_tex

func _physics_process(delta: float) -> void:
	if knockback_velocity.length() > 0.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 900.0 * delta)
		move_and_slide()
		return

	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if stun_time > 0.0:
		stun_time -= delta
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		move_and_slide()
		return

	if player_chase and player:
		var direction := (player.global_position - global_position).normalized()
		var distance := global_position.distance_to(player.global_position)

		if distance < LUNGE_RANGE:
			lunge_time = 0.3

		var chase_speed := LUNGE_SPEED if lunge_time > 0.0 else speed
		if lunge_time > 0.0:
			lunge_time -= delta
			velocity = direction * LUNGE_SPEED
			_play_attack_anim(direction)
		else:
			velocity = direction * speed
			_play_walk_anim(direction)

		move_and_slide()

		# If pushing against a tree/wall, slide sideways around it
		if get_slide_collision_count() > 0 and get_real_velocity().length() < chase_speed * 0.4:
			velocity = Vector2(-direction.y, direction.x) * chase_speed
			move_and_slide()
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		move_and_slide()

func _play_walk_anim(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("walk_side")
		animated_sprite.flip_h = direction.x < 0
	elif direction.y < 0:
		animated_sprite.play("walk_back")
	else:
		animated_sprite.play("walk_forward")

func _play_attack_anim(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("attack_side")
		animated_sprite.flip_h = direction.x < 0
	elif direction.y < 0:
		animated_sprite.play("attack_back")
	else:
		animated_sprite.play("attack_forward")

func take_damage(amount: int, knock_dir: Vector2) -> void:
	if is_dead:
		return
	health -= amount
	_update_hearts()
	if health <= 0:
		die(knock_dir)
	else:
		modulate = Color(3.0, 3.0, 3.0)
		var flash_tween := create_tween()
		flash_tween.tween_property(self, "modulate", Color.WHITE, 0.15)
		knock_back(knock_dir, 140.0)

func knock_back(direction: Vector2, strength: float) -> void:
	# A miniboss doesn't fly around like a slime
	knockback_velocity = direction * strength * 0.6
	stun_time = 0.25

func die(knock_dir: Vector2) -> void:
	is_dead = true
	remove_from_group("enemies")
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	detection_area.set_deferred("monitoring", false)
	player_chase = false
	for heart in hearts:
		heart.visible = false
	modulate = Color.WHITE
	knockback_velocity = knock_dir.normalized() * 100.0
	animated_sprite.play("death")
	animated_sprite.speed_scale = 1.5
	var death_tween := create_tween()
	death_tween.tween_property(animated_sprite, "scale", Vector2.ZERO, 0.4).set_ease(Tween.EASE_IN)
	var free_timer := get_tree().create_timer(0.8)
	free_timer.timeout.connect(queue_free)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_dead or body == self or not body.is_in_group("player"):
		return
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_chase = false
