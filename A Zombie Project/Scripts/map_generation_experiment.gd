extends Node2D

@onready var tile_map = $TileMap
@onready var rooms = $Rooms

var room = preload("res://Scenes/map_generation_experiment_room.tscn")

var room_size_min: int = 4
var room_size_max: int = 10
var room_quantity: int = 100
var tile_size: int = 64
var horizontal_spread = 600
var vertical_spread = 400
var culling_coefficient: float = 0.8 #percentage of rooms to delete

var path: AStar2D
@onready var count: int  = 0

func _ready():
	randomize()
	make_rooms()
	
func _process(delta):
	queue_redraw()
	
func _input(event):
	if Input.is_action_just_pressed('ui_select'):
		for r in rooms.get_children():
			r.queue_free()
			path = AStar2D.new()
		make_rooms()
	
	if Input.is_action_pressed('ui_focus_next'):
		make_tilemap()
		
func _draw():
	for r in rooms.get_children():
		var r_size = r.collision_shape_2d.shape.size
		draw_rect(Rect2(r.position - r_size / 2, r_size), Color(32, 228, 0), false)
		
	if path:
		for ids in path.get_point_ids():
			for connection in path.get_point_connections(ids):
				var point_position = path.get_point_position(ids)
				var connection_position = path.get_point_position(connection)
				draw_line(point_position, connection_position, Color(1, 1, 0), 15, true)


func make_rooms():
	for q in range(room_quantity):
		var new_room = room.instantiate()
		var pos = Vector2(randi_range(-horizontal_spread, horizontal_spread), randi_range(-vertical_spread, vertical_spread))
		var w = randi_range(room_size_min, room_size_max)
		var h = randi_range(room_size_min, room_size_max)
		rooms.add_child(new_room)
		new_room.make_room(pos, Vector2(w, h) * tile_size)
		
	# wait for physics engine to stop spreading rooms
	await get_tree().create_timer(1).timeout
	
	var room_positions: Array = []
	
	for r in rooms.get_children():
		if randf() < culling_coefficient:
			r.queue_free()
		else:
			r.freeze = true
			room_positions.append(r.position)
	
	await get_tree().create_timer(0.5).timeout
	
	# generate minimum spanning tree to connect all the roons
	
	find_mst(room_positions)
	
func find_mst(nodes) -> AStar2D:
	#implementation of prim's algorithm
	path = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	# repeat algorithm until no nodes remain
	while nodes:
		var min_distance = INF
		var min_position = null
		var current_position = null
		# iterate through points in path, at first iteration path contains only one point
		for point_id in path.get_point_ids():
			var point_id_position = path.get_point_position(point_id)
			# iterate through nodes ind nodes
			for node in nodes:
				#upon finding new shortest distance
				if point_id_position.distance_to(node) < min_distance:
					min_distance = point_id_position.distance_to(node)
					min_position = node
					current_position = point_id_position
		var id = path.get_available_point_id()
		# add node in nodes that had shortest distance to point_id to path
		path.add_point(id, min_position)
		# create connection
		path.connect_points(path.get_closest_point(current_position), id)
		# remove connect node from nodes
		nodes.erase(min_position)
	return path
			
func make_tilemap():
	tile_map.clear()
	# find full_rect = smallest rectangle that encompases all rooms
	var full_rect: Rect2
	for room in rooms.get_children():
		var room_size = room.collision_shape_2d.shape.size
		var room_rect: Rect2 = Rect2(room.position - room_size / 2, room_size)
		full_rect = full_rect.merge(room_rect)
	
	var top_left = tile_map.local_to_map(full_rect.position)
	var bottom_right = tile_map.local_to_map(full_rect.end)
	
	var cell_array: Array = []
	
	for x in range(top_left.x - 2, bottom_right.x + 2):
		for y in range(top_left.y - 2, bottom_right.y + 2):
			cell_array.append(Vector2i(x, y))

	tile_map.set_cells_terrain_connect(0,cell_array, 0, 1)
	
	var corriders: Array = [] # one corrider per connection.start and connectiont.end
	
	# Carve out rooms
	for room in rooms.get_children():
		var rcs: Vector2 = room.collision_shape_2d.shape.size
		var room_size: Vector2i = Vector2i(floor(rcs.x), floor(rcs.y))
		var room_position = Vector2i(floor(room.position.x), floor(room.position.y))
		var room_rect: Rect2 = Rect2(room_position - room_size / 2, room_size)
		
		var room_top_left = tile_map.local_to_map(room_rect.position)
		var room_bottom_right = tile_map.local_to_map(room_rect.end)
		
		var room_cell_array: Array = []
		
		var closest_point = path.get_closest_point(room_position)
		
		for connection in path.get_point_connections(closest_point):
			if not connection in corriders:
				var corrider_start = tile_map.local_to_map(path.get_point_position(closest_point))
				var corrider_end = tile_map.local_to_map(path.get_point_position(connection))
				
				carve_corrider(corrider_start, corrider_end)
		corriders.append(closest_point)
		
		for x in range(room_top_left.x + 1, room_bottom_right.x):
			for y in range(room_top_left.y + 1, room_bottom_right.y):
				room_cell_array.append(Vector2i(x, y))
				
		tile_map.set_cells_terrain_connect(0, room_cell_array, 0, 0)
	print(corriders.size())
	
func carve_corrider(start, end):
	
	# this finds what direction along the x and y axis must be carved
	var difference_x = sign(end.x - start.x)
	var difference_y = sign(end.y - start.y)
	# differece_y and differece_x bust be equal to either -1 or 1
	if difference_x == 0:
		difference_x = pow(-1.0, randi() % 2)
	if difference_y == 0:
		difference_y = pow(-1.0, randi() % 2)
		
	var x_over_y = start
	var y_over_x = end
	
	if randi() % 2 > 0:
		x_over_y = end
		y_over_x = start
	
	for x in range(start.x, end.x, difference_x):
		tile_map.set_cells_terrain_connect(0, [Vector2i(x, y_over_x.y)], 0, 0)
		tile_map.set_cells_terrain_connect(0, [Vector2i(x, y_over_x.y + difference_y)], 0, 0)
	for y in range(start.y, end.y, difference_y):
		tile_map.set_cells_terrain_connect(0, [Vector2i(x_over_y.x, y)], 0, 0)
		tile_map.set_cells_terrain_connect(0, [Vector2i(x_over_y.x + difference_x, y)], 0, 0)

