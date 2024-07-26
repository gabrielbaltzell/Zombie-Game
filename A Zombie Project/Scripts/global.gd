extends Node

var game_start_path: String = "res://Scenes/main.tscn"

var player = null
var inventory_interface = null

var current_scene = null
var old_scene = null

var player_just_moved: bool
var game_restart: bool = false


func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	initialize_scene(current_scene)
	player_just_moved = false

func go_to_scene(path):
	call_deferred('deffered_go_to_scene', path)
	
func deffered_go_to_scene(path):
	old_scene = current_scene.scene_file_path
	current_scene.free()
	var new_scene = ResourceLoader.load(path)
	current_scene = new_scene.instantiate()
	get_tree().get_root().add_child(current_scene)
	
	if not game_restart:
		identify_door_collision_pos(current_scene, old_scene)
		
	initialize_scene(current_scene)
	game_restart = false
func place_player():
	pass
	
func identify_door_collision_pos(new_scene, _old_scene):
	print(old_scene)
	var doors = new_scene.get_tree().get_nodes_in_group('door')
	for door in doors:
		print(door.target_scene_path)
		if door.target_scene_path == old_scene:
			var _player = new_scene.find_child('player')
			_player.position = door.position
	
func initialize_scene(scene):
	player = scene.find_child('player')
	inventory_interface = scene.find_child('InventoryInterface')

func restart_game():
	game_restart = true
	go_to_scene(game_start_path)
	
