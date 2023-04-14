extends TileMap

const buildings: Array[Vector2i] = [
	Vector2i(0, 19),
	Vector2i(1, 19),
	Vector2i(2, 19),
	Vector2i(3, 19),
	Vector2i(4, 19),
	Vector2i(5, 19),
	Vector2i(6, 19),
	Vector2i(7, 19),
	Vector2i(8, 20),
	Vector2i(0, 20),
	Vector2i(1, 20),
	Vector2i(2, 20),
	Vector2i(3, 20),
	Vector2i(4, 20),
	Vector2i(5, 20),
	Vector2i(6, 20),
	Vector2i(7, 20),
	Vector2i(8, 20),
	Vector2i(0, 21),
	Vector2i(1, 21),
	Vector2i(2, 21),
	Vector2i(3, 21),
	Vector2i(4, 21),
	Vector2i(5, 21),
	Vector2i(6, 21),
	Vector2i(7, 21),
	Vector2i(8, 21)
]
const trees: Array[Vector2i] = [
	Vector2i(0,1),
	Vector2i(1,1),
	Vector2i(2,1),
	Vector2i(3,1),
	Vector2i(4,1),
	Vector2i(5,1),
	Vector2i(6,1),
	Vector2i(7,1),
	Vector2i(0,2),
	Vector2i(1,2),
	Vector2i(2,2),
	Vector2i(3,2),
	Vector2i(4,2)
]
const PLAYER_SPRITE: Vector2i = Vector2i(24, 7)
var player_placement_cell: Vector2i
const rings: Array[Vector2i] = [
	Vector2i(43, 6),
	Vector2i(44, 6),
	Vector2i(45, 6),
	Vector2i(46, 6)
]
var ring_placement_cell: Vector2i

var noise: FastNoiseLite
@export_enum("Perlin", "Simplex", "Simplex Smooth") var noise_type: String = "Simplex Smooth"
@export var fractal_type: FastNoiseLite.FractalType
@export var cellular_distance_type: FastNoiseLite.CellularDistanceFunction
@export_range(0.0, 1.0) var noise_frequency: float = 0.01

#@onready var timer: Timer = Timer.new()
#@export_range(10, 200, 10) var player_movement_speed: int = 100 
@export_range(-1.0, 1.0) var tree_cap: float = -0.048
@export_range(-1.0, 1.0) var building_cap: float = -0.252
@export_range(0.0, 0.5) var building_overtakes_tree: float = 0.12
var x_tile_range: int = ProjectSettings.get_setting("display/window/size/viewport_width") / tile_set.tile_size.x
var y_tile_range: int = ProjectSettings.get_setting("display/window/size/viewport_height") / tile_set.tile_size.y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var start_time: float = Time.get_ticks_msec()
	set_noise()
	paint_tiles()
	place_player()
	place_ring()
	var new_time: float = Time.get_ticks_msec() - start_time
	print("Time taken: " + str(new_time) + "ms")

func _get_player_placement_cell() -> Vector2i:
	return Vector2i(randi() % x_tile_range, randi() % y_tile_range)

func place_player() -> void:
	while get_used_cells(0).has(player_placement_cell):
		player_placement_cell = _get_player_placement_cell()
	set_cell(0, player_placement_cell, 0, PLAYER_SPRITE)

func place_ring() -> void:
	while get_used_cells(0).has(ring_placement_cell):
		ring_placement_cell = _get_random_placement_cell()
	set_cell(0, ring_placement_cell, 0, rings.pick_random())

func _is_not_out_of_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < x_tile_range and cell.y >= 0 and cell.y < y_tile_range

func _physics_process(_delta: float) -> void:
	var previous_cell: Vector2i = player_placement_cell
	var direction: Vector2i = Vector2i.ZERO
	if Input.is_action_pressed("ui_up"): direction = Vector2i.UP
	elif Input.is_action_pressed("ui_down"): direction = Vector2i.DOWN
	elif Input.is_action_pressed("ui_left"): direction = Vector2i.LEFT
	elif Input.is_action_pressed("ui_right"): direction = Vector2i.RIGHT
	var new_placement_cell: Vector2i = player_placement_cell + direction
	if (not get_used_cells(0).has(new_placement_cell) or trees.has(get_cell_atlas_coords(0, new_placement_cell))) and _is_not_out_of_bounds(new_placement_cell):
		player_placement_cell = new_placement_cell
		set_cell(0, previous_cell, 0)
		set_cell(0, player_placement_cell, 0, PLAYER_SPRITE)

# ALGORITHM BEGINS HERE

func _get_noise_type() -> int:
	match noise_type:
		"Perlin": return 3
		"Simplex": return 0
		_: return 1 # Return Simplex Smooth by default

func set_noise() -> void:
	noise = FastNoiseLite.new()
	noise.frequency = noise_frequency
	noise.noise_type = _get_noise_type() as FastNoiseLite.NoiseType
	noise.fractal_type = fractal_type
	noise.cellular_distance_function = cellular_distance_type
	noise.seed = randi()

func paint_tiles() -> void:
	for x in range(x_tile_range):
		for y in range(y_tile_range):
			var noise_point: float = noise.get_noise_2d(x * tile_set.tile_size.x, y * tile_set.tile_size.y)
			if noise_point < tree_cap and not get_used_cells(0).has(Vector2i(x, y)):
				set_cell(0, Vector2i(x, y), 0, trees.pick_random())
			if ((building_cap <= tree_cap and randf() < building_overtakes_tree) or (building_cap > tree_cap and noise_point < building_cap)) and not get_used_cells(0).has(Vector2i(x, y)):
				set_cell(0, Vector2i(x, y), 0, buildings.pick_random())
