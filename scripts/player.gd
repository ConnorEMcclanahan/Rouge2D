extends CharacterBody2D

const SPEED = 100
const MAX_HEALTH = 3
const INVINCIBLE_TIME = 1.0
const KNOCKBACK_STRENGTH = 240.0
const ATTACK_WINDOW = 0.18
const HIT_STUN_TIME = 0.4
const HURT_FLASH_TIME = 0.25

const UiTheme = preload("res://scripts/ui_theme.gd")

@onready var animated_sprite = $AnimatedSprite2D

var hud = null
var attack_area: Area2D = null

var current_direction = "down"
var is_attacking = false
var is_dead = false
var invincible = false
var health: int = MAX_HEALTH
var attack_timer: SceneTreeTimer = null
var knockback_velocity: Vector2 = Vector2.ZERO
var hit_stun_time: float = 0.0
var hurt_flash_time: float = 0.0
var swing_hit_enemies: Array[Node] = []
var map_bounds: Rect2 = Rect2()
var nearby_interactable: Node = null
var prompt: Control

func _ready():
	add_to_group("player")
	collision_mask = 3  # tiles (1) + enemies (2); survives scene saves
	animated_sprite.play("front_idle")
	health = GameState.max_health
	_build_attack_hitbox()
	_build_hud()
	_setup_camera()
	_build_interact_prompt()

# Smooth camera follow + limits so you only ever see painted map content
func _setup_camera() -> void:
	var camera: Camera2D = $Camera2D
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	camera.limit_smoothed = true

	var world_root := get_tree().current_scene
	var ground: TileMapLayer = null
	if world_root:
		ground = world_root.get_node_or_null("ground") as TileMapLayer
	if ground and ground.tile_set:
		var cells: Rect2i = ground.get_used_rect()
		var ts: Vector2i = ground.tile_set.tile_size
		map_bounds = Rect2(Vector2(cells.position) * Vector2(ts), Vector2(cells.size) * Vector2(ts))
		camera.limit_left = int(map_bounds.position.x)
		camera.limit_top = int(map_bounds.position.y)
		camera.limit_right = int(map_bounds.end.x)
		camera.limit_bottom = int(map_bounds.end.y)

# The attack hitbox is built in code so the scene file stays untouched.
func _build_attack_hitbox() -> void:
	attack_area = Area2D.new()
	attack_area.name = "attack_area"
	attack_area.collision_layer = 0
	attack_area.collision_mask = 2  # Detect slimes (layer 2)
	attack_area.monitoring = false

	var shape_node := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	shape_node.shape = circle
	attack_area.add_child(shape_node)
	add_child(attack_area)

	attack_area.body_entered.connect(_on_attack_area_body_entered)

func _build_hud() -> void:
	hud = preload("res://scripts/hud.gd").new()
	hud.name = "HUD"
	add_child(hud)
	hud.set_max_health(GameState.max_health)
	hud.set_health(health)

func _process(delta: float) -> void:
	_update_prompt()

	# Red flash right after taking a hit, smoothly fading back to normal
	if hurt_flash_time > 0.0:
		hurt_flash_time -= delta
		var t := clampf(1.0 - hurt_flash_time / HURT_FLASH_TIME, 0.0, 1.0)
		animated_sprite.modulate = Color(2.0, 0.6, 0.6).lerp(Color.WHITE, t)
		return

	# Blink while invincible
	if invincible and not is_dead:
		animated_sprite.modulate.a = 0.35 if int(Time.get_ticks_msec() / 90) % 2 == 0 else 1.0


func _physics_process(delta):
	# Never walk out of the painted map
	if map_bounds.size != Vector2.ZERO:
		global_position.x = clampf(global_position.x, map_bounds.position.x + 6.0, map_bounds.end.x - 6.0)
		global_position.y = clampf(global_position.y, map_bounds.position.y + 6.0, map_bounds.end.y - 6.0)

	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Knockback from getting hit: no input while being pushed back
	if knockback_velocity.length() > 0.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_STRENGTH * 4.0 * delta)
		move_and_slide()
		_check_enemy_contact()
		return

	# Hit-stun: brief moment after a hit where you can't move or attack
	if hit_stun_time > 0.0:
		hit_stun_time -= delta
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		_check_enemy_contact()
		return

	# Spacebar: interact with whatever you're standing next to, otherwise attack
	if Input.is_action_just_pressed("ui_accept"):
		if nearby_interactable != null and nearby_interactable.has_method("interact"):
			nearby_interactable.interact()
		else:
			start_attack()
		return

	velocity = Vector2.ZERO

	# Check both WASD and Arrow Keys simultaneously
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		current_direction = "right"
		velocity.x = SPEED * GameState.speed_mult
		animated_sprite.flip_h = false
		animated_sprite.play("side_walk")
	elif Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		current_direction = "left"
		velocity.x = -SPEED * GameState.speed_mult
		animated_sprite.flip_h = true
		animated_sprite.play("side_walk")
	elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		current_direction = "down"
		velocity.y = SPEED * GameState.speed_mult
		animated_sprite.flip_h = false
		animated_sprite.play("front_walk")
	elif Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		current_direction = "up"
		velocity.y = -SPEED * GameState.speed_mult
		animated_sprite.flip_h = false
		animated_sprite.play("back_walk")
	else:
		velocity.x = 0
		velocity.y = 0
		if current_direction == "right" or current_direction == "left":
			animated_sprite.play("side_idle")
		elif current_direction == "down":
			animated_sprite.play("front_idle")
		elif current_direction == "up":
			animated_sprite.play("back_idle")

	move_and_slide()

	# Pokémon-style ledges: walking down into a cliff lets you hop off it
	if velocity.y > 0.0:
		for i in get_slide_collision_count():
			var ledge: Object = get_slide_collision(i).get_collider()
			if ledge is TileMapLayer and (ledge as TileMapLayer).name == "cliff":
				set_collision_mask_value(1, false)  # tiles off for this hop
				move_and_slide()
				set_collision_mask_value(1, true)
				break
	_check_enemy_contact()

# Touching a slime's solid body = take a hit (Zelda-style contact damage)
func _check_enemy_contact() -> void:
	if invincible or is_dead:
		return
	for i in get_slide_collision_count():
		var collider: Object = get_slide_collision(i).get_collider()
		if collider is Node and collider.is_in_group("enemies"):
			take_damage(1, collider as Node2D)
			break

func take_damage(amount: int, source: Node2D) -> void:
	if invincible or is_dead:
		return
	health -= amount
	hud.set_health(health)
	hud.shake()

	if health <= 0:
		die()
		return

	invincible = true
	hit_stun_time = HIT_STUN_TIME
	hurt_flash_time = HURT_FLASH_TIME
	animated_sprite.modulate = Color(2.0, 0.6, 0.6)
	var knock_dir: Vector2 = (global_position - source.global_position).normalized()
	knockback_velocity = knock_dir * KNOCKBACK_STRENGTH * GameState.knockback_mult

	# Make the slime recoil too so it can't pin you against itself
	if source.has_method("knock_back"):
		source.knock_back(knock_dir, 170.0)

	var invincible_timer := get_tree().create_timer(INVINCIBLE_TIME * GameState.iframe_mult)
	invincible_timer.timeout.connect(func() -> void:
		invincible = false
		animated_sprite.modulate.a = 1.0
	)


func die() -> void:
	is_dead = true
	invincible = false
	animated_sprite.modulate = Color.WHITE
	animated_sprite.play("dead")
	var game_over_timer := get_tree().create_timer(1.2)
	game_over_timer.timeout.connect(_show_game_over)

func _show_game_over() -> void:
	var game_over = preload("res://scripts/game_over.gd").new()
	game_over.name = "GameOver"
	get_tree().current_scene.add_child(game_over)

func start_attack():
	if is_attacking or is_dead:
		return
	is_attacking = true
	velocity = Vector2.ZERO

	if current_direction == "right" or current_direction == "left":
		animated_sprite.play("side_attack")
	elif current_direction == "down":
		animated_sprite.play("front_attack")
	elif current_direction == "up":
		animated_sprite.play("back_attack")

	_activate_attack_hitbox()

	attack_timer = get_tree().create_timer(GameState.attack_cooldown)
	attack_timer.timeout.connect(func():
		is_attacking = false
	)

# Sword swing: hitbox placed ~1-1.5 tiles in front of the player
func _activate_attack_hitbox() -> void:
	var forward := Vector2.DOWN
	match current_direction:
		"right":
			forward = Vector2.RIGHT
		"left":
			forward = Vector2.LEFT
		"up":
			forward = Vector2.UP

	attack_area.position = Vector2(0, -6) + forward * 24.0
	attack_area.monitoring = true
	swing_hit_enemies.clear()
	_apply_swing_hits()

	var window_timer := get_tree().create_timer(ATTACK_WINDOW)
	window_timer.timeout.connect(func() -> void:
		attack_area.monitoring = false
	)

# Wait one physics frame so overlaps update, then hit what's already inside
func _apply_swing_hits() -> void:
	await get_tree().physics_frame
	if is_dead:
		return
	for body in attack_area.get_overlapping_bodies():
		_hit_slime(body)

func _on_attack_area_body_entered(body: Node2D) -> void:
	_hit_slime(body)

func _hit_slime(body: Node2D) -> void:
	if not body.is_in_group("enemies"):
		return
	if swing_hit_enemies.has(body):
		return
	swing_hit_enemies.append(body)
	var knock_dir: Vector2 = (body.global_position - global_position).normalized()
	if body.has_method("take_damage"):
		body.take_damage(GameState.attack_damage, knock_dir)

# ---- Roguelike upgrade / interact plumbing ---------------------------------

func set_nearby_interactable(node: Node) -> void:
	nearby_interactable = node

func clear_nearby_interactable(node: Node) -> void:
	if nearby_interactable == node:
		nearby_interactable = null

func refresh_from_gamestate() -> void:
	health = GameState.max_health if GameState.pending_heal else clampi(health, 0, GameState.max_health)
	GameState.pending_heal = false
	hud.set_max_health(GameState.max_health)
	hud.set_health(health)

func _build_interact_prompt() -> void:
	prompt = UiTheme.make_keycap("SPACE", 10)
	prompt.name = "InteractPrompt"
	prompt.visible = false
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(prompt)

func _update_prompt() -> void:
	var show := nearby_interactable != null and not is_dead
	if show and not prompt.visible:
		prompt.reset_size()
	prompt.visible = show
	if show:
		var bob := sin(Time.get_ticks_msec() * 0.006) * 2.0
		prompt.global_position = global_position + Vector2(-prompt.size.x * 0.5, -46.0 + bob)
