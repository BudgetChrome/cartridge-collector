extends Area2D

@onready var player = get_parent()



func _on_body_entered(body):
	if body.name == "SpikeTiles":
		player.take_damage(2)
	elif body.is_in_group("enemy"):
		if not body.dead:
			player.take_damage(1)
	elif body.is_in_group("pickups"):
		player.pickup_heal(body)
	elif body.name == "LadderTileMap":
		print("ladder time")
	elif body.is_in_group("win"):
		player.win()
		body.queue_free()
