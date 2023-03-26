extends Area2D

@export var slot_data: SlotData

@onready var sprite_2d = $Sprite2D


func _ready():
	initialize_pick_up.call_deferred()
	#sprite_2d.texture = slot_data.item_data.texture
	pass
	#print(slot_data, 'pickup.gd')

func _physics_process(_delta):
	pass

func _on_body_entered(body):
	if body.inventory_data.pick_up_slot_data(slot_data):
		queue_free()

func initialize_pick_up():
	print(slot_data, 'pickup.gd')
	#sprite_2d.texture = slot_data.item_data.texture
	
	
