extends TextureRect

@onready var cartridge = $"."

func _ready():
	if GlobalData.level_1_complete:
		cartridge.self_modulate = Color(0.678, 0.365, 0.251)
