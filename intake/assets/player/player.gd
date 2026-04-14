extends CharacterBody2D

var GRAVITY_POWER = 2000.0
var MSPEED = 300.0
var JUMP_FORCE = -650
var HOLD_GRAVITY_MULTIPLIER = 0.5
var STUN_TIME = 0.3
var INVINCIBILITY_TIME = 1.3
@export var SPEED_MULTIPLIER = 1

var max_health = 4
var health = 4
var invincible = false
var stunned = false
var won = false

var hurt_knockback_x = 220.0
var hurt_knockback_y = -260.0
var facing = 1

@export var bullet_scene: PackedScene
@onready var shoot_point = $ShootPoint
@onready var sprite = $AnimatedSprite2D
@onready var UI = $"CanvasLayer/MarginContainer"

func apply_gravity(delta):
	var gravity = GRAVITY_POWER
	
	if Input.is_action_pressed("jump") and velocity.y < 0:
		gravity *= HOLD_GRAVITY_MULTIPLIER
	
	velocity.y = clampf(velocity.y + gravity * delta, -2600, 1300)

func death():
	get_tree().change_scene_to_file("res://assets/world/scenes/intro_scene.tscn")

func hurt_feedback():
	invincible = true
	stunned = true

	# knockback opposite of facing direction
	velocity.x = -facing * hurt_knockback_x
	velocity.y = hurt_knockback_y

	sprite.play("stagger")

	# short stun
	await get_tree().create_timer(STUN_TIME).timeout
	stunned = false

	# flicker during invincibility
	await flicker_invincibility(INVINCIBILITY_TIME)

	invincible = false
	sprite.visible = true

func flicker_invincibility(duration):
	var elapsed = 0.0
	while elapsed < duration:
		sprite.visible = !sprite.visible
		await get_tree().create_timer(0.08).timeout
		elapsed += 0.08

	sprite.visible = true

func take_damage(amount):
	if invincible:
		return
	
	invincible = true
	health -= amount
	update_health_ui()
	
	if health <= 0:
		death()
		return
	
	await hurt_feedback()

func update_health_ui():
	UI.get_node("Battery1").visible = health >= 1
	UI.get_node("Battery2").visible = health >= 2
	UI.get_node("Battery3").visible = health >= 3
	UI.get_node("Battery4").visible = health >= 4

func pickup_heal(body):
	if health != max_health:
		body.queue_free()
		health += 1
		update_health_ui()
	else:
		body.pickup_flash()

func fire():
	var bullet = bullet_scene.instantiate()
	bullet.flip(facing)
	bullet.global_position = shoot_point.global_position
	get_tree().current_scene.add_child(bullet)

func win():
	invincible = true
	velocity = Vector2(0,0)
	stunned = true
	won = true
	GlobalData.level_1_complete = true
	await get_tree().create_timer(1).timeout
	stunned = false

func _ready():
	update_health_ui()

func _physics_process(delta):
	var input_direction = Input.get_axis("left", "right")
	
	if won and not stunned:
		if Input.is_anything_pressed():
			get_tree().change_scene_to_file("res://assets/world/scenes/finish_scene.tscn")
	
	if not stunned:
		velocity.x = input_direction * MSPEED * SPEED_MULTIPLIER

		if input_direction < 0:
			facing = -1
			sprite.flip_h = true
		elif input_direction > 0:
			facing = 1
			sprite.flip_h = false
			
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_FORCE
			
		if Input.is_action_just_pressed("fire"):
			fire()

	if not is_on_floor():
		apply_gravity(delta)

	if Input.is_action_just_pressed("debug"):
		velocity.y = JUMP_FORCE * 2
		health = max_health
		update_health_ui()

	move_and_slide()
	
	if position.y > 5000:
		death()

	if won:
		if sprite.animation != "yay":
			sprite.play("yay")
	elif stunned:
		if sprite.animation != "stagger":
			sprite.play("stagger")
	elif not is_on_floor():
		if sprite.animation != "jump":
			sprite.play("jump")
	elif input_direction != 0:
		if sprite.animation != "walk":
			sprite.play("walk")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")
