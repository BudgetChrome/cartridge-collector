extends CharacterBody2D

var speed_x = 80.0
var speed_y = 50.0
var dead = false
var aggro_range = 750.0
var y_snap_range = 8.0

@export var energy_scene: PackedScene
@onready var player = findPlayer()
@onready var sprite = $AnimatedSprite2D

@export var max_health = 3
@export var health = 3

var death_fall_speed = 150.0
var death_x_slowdown = 200.0
var death_y_slowdown = 250.0

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

func death():
	dead = true

	velocity.x = -velocity.x * 2

	velocity.y = death_fall_speed

	sprite.play("death")

	await get_tree().create_timer(0.7).timeout
	
	if findPlayer().health <= 2:
		if randf() < 0.8:
			var energy = energy_scene.instantiate()
			energy.global_position = global_position
			get_tree().current_scene.add_child(energy)
	
	queue_free()

func _ready():
	sprite.play("default")

func take_damage(amount):
	health -= amount
	
	if health <= 0 and not dead:
		sprite.modulate = Color(255,255,255,2)
		death()
	else:
		flash(1.6)

func _physics_process(delta):
	if not dead:
		if player == null:
			player = findPlayer()
			return

		var distance_x = abs(player.global_position.x - global_position.x)

		if distance_x <= aggro_range:
			var dir_x = sign(player.global_position.x - global_position.x)
			velocity.x = dir_x * speed_x

			var delta_y = player.global_position.y - global_position.y

			if abs(delta_y) <= y_snap_range:
				velocity.y = 0
			else:
				velocity.y = sign(delta_y) * speed_y
		else:
			velocity = Vector2.ZERO
	else:
		velocity.x = move_toward(velocity.x, 0.0, death_x_slowdown * delta)

		velocity.y = move_toward(velocity.y, 0.0, death_y_slowdown * delta)

	move_and_slide()
