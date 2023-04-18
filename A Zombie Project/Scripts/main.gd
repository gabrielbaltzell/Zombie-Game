extends Node

const PickUp = preload("res://Scenes/pick_up.tscn")

@onready var tile_map = $NavigationRegion2D/TileMap
@onready var player = $player
@onready var inventory_interface = $UI/InventoryInterface
@onready var hot_bar_inventory = $UI/HotBarInventory
var is_inventory_interface_visible = false

var tile_map_collision_rect: Rect2

var layer_1_used_cells: Array
var player_position_cell: Vector2i

func _ready() -> void:
	randomize()
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	hot_bar_inventory.set_inventory_data(player.inventory_data)
	
	for node in get_tree().get_nodes_in_group('external_inventory'):
		node.toggle_inventory.connect(toggle_inventory_interface)
		
	layer_1_used_cells = []
	layer_1_used_cells = tile_map.get_used_cells_by_id(1, 0)
	print(layer_1_used_cells)
	
func _process(delta):
	print(tile_map.get_cell_atlas_coords(0, Vector2i(floor(player.position.x), floor(player.position.y))))
	
func toggle_inventory_interface(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
		
	else:
		inventory_interface.clear_external_inventory()
	
	if inventory_interface.visible:
		hot_bar_inventory.hide()
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		hot_bar_inventory.show()
		#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		
# emitted from inventor_interface.gd 
func _on_inventory_interface_drop_slot_data(_slot_data):
	var pick_up = PickUp.instantiate()
	pick_up.slot_data = _slot_data
	pick_up.position = player.get_drop_position()
	add_child(pick_up)




