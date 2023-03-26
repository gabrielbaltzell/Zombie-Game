extends Node

const PickUp = preload("res://Scenes/pick_up.tscn")

@onready var player = $player
@onready var inventory_interface = $UI/InventoryInterface
var is_inventory_interface_visible = false

func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	
	for node in get_tree().get_nodes_in_group('external_inventory'):
		node.toggle_inventory.connect(toggle_inventory_interface)
	
func toggle_inventory_interface(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
		
	else:
		inventory_interface.clear_external_inventory()
	
	#if inventory_interface.visible:
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#else:
		#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		
# emitted from inventor_interface.gd 
func _on_inventory_interface_drop_slot_data(slot_data):
	print(slot_data, 'main')
	var pick_up = PickUp.instantiate()
	add_child(pick_up)
	pick_up.slot_data = slot_data
	print(pick_up.slot_data)
	#pick_up.initialize_pick_up()
	pick_up.position = Vector2.UP
	#$PickUp.initialize_pick_up()
