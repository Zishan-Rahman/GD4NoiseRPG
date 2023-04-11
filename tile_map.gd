extends TileMap

var trees: Array[Vector2i] = [Vector2i(0,1),Vector2i(1,1),Vector2i(2,1),Vector2i(5,1),Vector2i(6,1),Vector2i(4,2)]
@onready var NoiseSprite: Sprite2D = $Sprite2D
@export_range(-1.0, 1.0) var tree_cap: float = 0.0
var x_tile_range: int = ProjectSettings.get_setting("display/window/size/viewport_width") / tile_set.tile_size.x
var y_tile_range: int = ProjectSettings.get_setting("display/window/size/viewport_height") / tile_set.tile_size.y

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(x_tile_range):
		for y in range(y_tile_range):
			var noise_point: float = NoiseSprite.texture.noise.get_noise_2d(x * tile_set.tile_size.x, y * tile_set.tile_size.y)
			if noise_point < tree_cap:
				set_cell(0, Vector2i(x, y), 0, trees.pick_random())
