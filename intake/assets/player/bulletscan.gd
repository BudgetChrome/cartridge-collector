extends Area2D

var SPEED = 1250.0
var SPEED_MULTIPLIER = 1
var facing = 1
var DISTANCE = 0
var damage = 1
var MAX_DISTANCE = 1000
var smoke_time = 0.1

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("default")

func fade_out():
	$AnimatedSprite2D.play("impact")
	SPEED = 0
	await get_tree().create_timer(smoke_time).timeout
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemy") and not body.dead:
		body.take_damage(damage)
		fade_out()

func flip(direction):
	if direction < 0:
		facing = -1
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:
		facing = 1
		$AnimatedSprite2D.flip_h = false

func _on_breaker_body_entered(_body):
	fade_out()

func _physics_process(delta):
	var velocity = SPEED * facing * delta
	DISTANCE += abs(velocity)
	position.x += velocity
	
	if DISTANCE > MAX_DISTANCE:
		queue_free()
