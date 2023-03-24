extends Node

var player = null
var inventory_interface = null

var current_scene = null
var old_scene = null

var player_just_moved: bool


func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	initialize_scene(current_scene)
	player_just_moved = false
	print(player)

func go_to_scene(path):
	call_deferred('deffered_go_to_scene', path)
	
func deffered_go_to_scene(path):
	old_scene = current_scene.scene_file_path
	current_scene.free()
	var new_scene = ResourceLoader.load(path)
	current_scene = new_scene.instantiate()
	get_tree().get_root().add_child(current_scene)
	identify_door_collision_pos(current_scene, old_scene)
	initialize_scene(current_scene)
func place_player():
	pass
	
func identify_door_collision_pos(new_scene, old_scene):
	print(old_scene)
	var doors = new_scene.get_tree().get_nodes_in_group('door')
	for door in doors:
		print(door.target_scene_path)
		if door.target_scene_path == old_scene:
			var player = new_scene.find_child('player')
			player.position = door.global_position
	
func initialize_scene(scene):
	player = scene.find_child('player')
	inventory_interface = scene.find_child('InventoryInterface')


