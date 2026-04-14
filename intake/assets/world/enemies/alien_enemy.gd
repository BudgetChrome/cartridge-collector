extends CharacterBody2D

var GRAVITY_POWER = 2000.0
var MSPEED = 200.0
var JUMP_FORCE = -350
var SPEED_MULTIPLIER = 1
var dead = false

@export var energy_scene: PackedScene
var energy_offset = Vector2(0, 50)

@export var SLOW_DURATION = 0.0
@export var SLOW_MAX_DURATION = 1.0
@export var facing = 1

var STUN_TIME = 0.3

var max_health = 5
var health = 5
var stunned = false
var taking_hit = false

var hurt_knockback_x = 440.0
var hurt_knockback_y = -260.0

@onready var sprite = $AnimatedSprite2D
@onready var ground_check = $GroundCheck

var flashing = false
var flash_duration = 0.08

func flash(amount):
	if flashing:
		return
	
	flashing = true
	sprite.modulate = Color(amount, amount, amount)
	await get_tree().create_timer(flash_duration).timeout
	
	if flashing: 
		sprite.modulate = Color(1,1,1)
		flashing = false

func findPlayer():
	return get_tree().get_first_node_in_group("player")

func slow_down():
	SLOW_DURATION = SLOW_MAX_DURATION

func death():
	if dead:
		return

	dead = true
	stunned = true
	taking_hit = false
	velocity.x = 0
	sprite.play("stagger")

	await get_tree().create_timer(0.7).timeout
	
	if findPlayer().health <= 2:
		if randf() < 0.8:
			var energy = energy_scene.instantiate()
			energy.global_position = global_position + energy_offset
			get_tree().current_scene.add_child(energy)
	
	queue_free()

func hurt_feedback():
	if dead or taking_hit:
		return

	taking_hit = true
	stunned = true

	var player = findPlayer()
	if player != null:
		var dir_x = sign(player.global_position.x - global_position.x)

		if dir_x != 0 and dir_x != facing:
			turn_around()


	velocity.x = -facing * hurt_knockback_x
	velocity.y = hurt_knockback_y

	await get_tree().create_timer(STUN_TIME).timeout

	if not dead:
		stunned = false
		slow_down()

	taking_hit = false

func take_damage(amount):
	if dead:
		return
	health -= amount

	if health <= 0:
		sprite.modulate = Color(255,255,255,2)
		flashing = false
		death()
	else:
		flash(1.6)
		hurt_feedback()

func turn_around():
	facing *= -1
	ground_check.position.x *= -1
	sprite.flip_h = !sprite.flip_h
	slow_down()

func apply_gravity(delta):
	velocity.y = clampf(velocity.y + GRAVITY_POWER * delta, -2600, 1300)

func _ready():
	if facing == -1:
		sprite.flip_h = true
		ground_check.position.x *= -1

func _physics_process(delta):
	if not dead and not stunned:
		if is_on_wall() or (is_on_floor() and not ground_check.is_colliding()):
			turn_around()

		if SLOW_DURATION > 0:
			SPEED_MULTIPLIER = 0.5
			sprite.speed_scale = 0.5
			SLOW_DURATION = clamp(SLOW_DURATION - delta, 0.0, INF)
		else:
			SPEED_MULTIPLIER = 1.0
			sprite.speed_scale = 1.0

		velocity.x = facing * MSPEED * SPEED_MULTIPLIER

	elif stunned and not dead:
		velocity.x = move_toward(velocity.x, 0.0, 900 * delta)

	if not is_on_floor():
		apply_gravity(delta)

	move_and_slide()

	if position.y > 5000:
		death()

	if dead:
		if sprite.animation != "stagger":
			sprite.play("stagger")
		return

	if stunned:
		if sprite.animation != "stagger":
			sprite.play("stagger")
		return

	if not is_on_floor():
		if sprite.animation != "jump":
			sprite.play("jump")
	elif velocity.x != 0:
		if sprite.animation != "walk":
			sprite.play("walk")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")
