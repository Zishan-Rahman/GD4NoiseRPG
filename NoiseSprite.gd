extends Sprite2D

func _ready():
	randomize()
	texture.noise.seed = randi() 
