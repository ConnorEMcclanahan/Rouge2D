extends CharacterBody2D
## "Bones" — miniboss logic for the user-built bones.tscn scene.
## 4 hearts, chases the player, lunges up close. Everything is hearts, no bars.

const UiTheme = preload("res://scripts/ui_theme.gd")

@export var speed: float = 35.0
@export var health: int = MAX_HEALTH

const MAX_HEALTH := 4
const LUNGE_RANGE := 40.0
const ATTACK_TIME := 0.6
const ATTACK_COOLDOWN := 0.8
const DASH_SPEED := 90.0

var player_chase: bool = false
var player: Node2D = null
var is_dead: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var stun_time: float = 0.0
var attack_time: float = 0.0
var attack_cooldown: float = 0.0
var attack_direction: Vector2 = Vector2.ZERO

var full_heart_tex: ImageTexture
var empty_heart_tex: ImageTexture
var hearts: Array[TextureRect] = []

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $detection_area

func _ready() -> void:
	add_to_group("enemies")
	collision_mask = 3  # player (2) + tiles (1)

	detection_area.collision_layer = 2
	detection_area.collision_mask = 2
	var area_shape: CircleShape2D = $detection_area/CollisionShape2D.shape
	area_shape.radius = 120.0
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

	_build_hearts()

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

		# Attack sequence: short dash, then hold still while the swing finishes
		if attack_time > 0.0:
			attack_time -= delta
			animated_sprite.speed_scale = 2.0
			animated_sprite.play("attack")
			animated_sprite.flip_h = attack_direction.x < 0
			velocity = attack_direction * DASH_SPEED if attack_time > 0.35 else Vector2.ZERO
			move_and_slide()
			return

		if attack_cooldown > 0.0:
			attack_cooldown -= delta

		# When close enough, start a telegraphed attack
		if distance < LUNGE_RANGE and attack_cooldown <= 0.0:
			attack_time = ATTACK_TIME
			attack_cooldown = ATTACK_COOLDOWN
			attack_direction = direction
			velocity = Vector2.ZERO
			move_and_slide()
			return

		# Slow stalk toward the player
		animated_sprite.speed_scale = 1.0
		velocity = direction * speed
		animated_sprite.play("walk_side")
		animated_sprite.flip_h = direction.x < 0

		move_and_slide()

		# If pushing against a tree/wall, slide sideways around it
		if get_slide_collision_count() > 0 and get_real_velocity().length() < speed * 0.4:
			velocity = Vector2(-direction.y, direction.x) * speed
			move_and_slide()
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		move_and_slide()

func take_damage(amount: int, knock_dir: Vector2) -> void:
	if is_dead:
		return
	health -= amount
	_update_hearts()
	if health <= 0:
		die(knock_dir)
	else:
		modulate = Color(3.0, 3.0, 3.0)
		animated_sprite.play("hurt")
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
	GameState.bones_defeated = true
	# Remove ALL collision immediately so the dying bones can never block the player
	collision_layer = 0
	collision_mask = 0
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
	detection_area.set_deferred("monitoring", false)
	player_chase = false
	for heart in hearts:
		heart.visible = false
	modulate = Color.WHITE
	knockback_velocity = knock_dir.normalized() * 100.0
	# The 17-frame death animation from the Enemy_Animations_Set sheet
	animated_sprite.play("death")
	animated_sprite.speed_scale = 3.0
	var death_tween := create_tween()
	death_tween.tween_property(animated_sprite, "scale", Vector2.ZERO, 1.1).set_ease(Tween.EASE_IN)
	var free_timer := get_tree().create_timer(1.2)
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
