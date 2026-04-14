extends StaticBody2D

var float_speed = 2.0
var float_amount = 6.0

var start_y = 0.0
var time = 0.0

@onready var sprite = $Sprite2D

var flashing = false
var flash_duration = 0.5
var flash_amount = 0.4



func pickup_flash():
	if flashing:
		return
	
	flashing = true
	sprite.modulate = Color(flash_amount, flash_amount, flash_amount)
	await get_tree().create_timer(flash_duration).timeout
	
	if flashing: 
		sprite.modulate = Color(1,1,1)
		flashing = false

func _ready():
	start_y = global_position.y
	time = randf() * TAU

func _process(delta):
	time += delta * float_speed
	global_position.y = start_y + sin(time) * float_amount
