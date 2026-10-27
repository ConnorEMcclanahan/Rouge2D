extends CharacterBody2D

@export var speed: float = 50.0
@export var health: int = 2

var player_chase: bool = false
var player: Node2D = null
var is_dead: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var stun_time: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $detection_area

func _ready() -> void:
	add_to_group("enemies")
	collision_mask = 3  # player (2) + tiles (1)

func _physics_process(delta: float) -> void:
	# Slide back from knockback (also used for the death bounce)
	if knockback_velocity.length() > 0.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1000.0 * delta)
		move_and_slide()
		return

	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Brief pause after being hit so the slime can't pin the player
	if stun_time > 0.0:
		stun_time -= delta
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		move_and_slide()
		return

	if player_chase and player:
		# Calculate direction toward the player
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed

		if abs(direction.x) > abs(direction.y):
			animated_sprite.play("walk_side")
			animated_sprite.flip_h = direction.x < 0
		else:
			if direction.y < 0:
				animated_sprite.play("walk_back")
			else:
				animated_sprite.play("walk_forward")
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")

	# This drives the actual movement in Godot 4
	move_and_slide()

func take_damage(amount: int, knock_dir: Vector2) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0:
		die(knock_dir)
	else:
		modulate = Color(3.0, 3.0, 3.0)
		# Smoothly fade the white flash back out
		var flash_tween := create_tween()
		flash_tween.tween_property(self, "modulate", Color.WHITE, 0.15)
		knock_back(knock_dir, 220.0)

func knock_back(direction: Vector2, strength: float) -> void:
	knockback_velocity = direction * strength
	stun_time = 0.35

func die(knock_dir: Vector2) -> void:
	is_dead = true
	remove_from_group("enemies")
	# Remove ALL collision immediately so the dying slime can never block the player
	collision_layer = 0
	collision_mask = 0
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
	detection_area.set_deferred("monitoring", false)
	player_chase = false
	modulate = Color.WHITE
	# Bounce away while playing the death animation
	knockback_velocity = knock_dir.normalized() * 220.0
	animated_sprite.play("death")
	animated_sprite.speed_scale = 2.0
	# Smooth shrink-out as it dies
	var death_tween := create_tween()
	death_tween.tween_property(animated_sprite, "scale", Vector2.ZERO, 0.35).set_ease(Tween.EASE_IN)
	var free_timer := get_tree().create_timer(0.7)
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
