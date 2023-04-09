extends Node

@onready var tile_map = $TileMap
@onready var sprite_2d = $Sprite2D

@export var speed: float = 1
@export var map_size: int = 1

var block: Array = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]

var floor = 0
var wall = 1

func _ready():
	for x in range(12):
		for y in range(12):
			if x % 2 == 1:
				if y % 2 == 1:
						tile_map.set_cells_terrain_connect(0, initialize_block(Vector2i(x, y)), 0, 0, true)
						print(Vector2i(x, y))
			
	#tile_map.set_cells_terrain_connect(0, initialize_block(Vector2i(1, 1)), 0, 0, true)
	#tile_map.set_cells_terrain_connect(0, initialize_block(Vector2i(3, 1)), 0, 0, true)
	#var tile_cell = tile_map.get_neighbor_cell(Vector2i(2, 1), 0)
	#var tile_cell_data = tile_map.get_cell_tile_data(0, tile_cell)
	#print(tile_cell_data.terrain)
	

func _process(delta):
	pass
	
func initialize_block(initial: Vector2i) -> Array:
	var block_array: Array
	block_array.insert(0, Vector2i(initial.x - 1, initial.y - 1))
	block_array.insert(1, Vector2i(initial.x, initial.y - 1))
	block_array.insert(2, Vector2i(initial.x, initial.y))
	block_array.insert(3, Vector2i(initial.x - 1, initial.y))
	#print(block_array)
	return block_array

