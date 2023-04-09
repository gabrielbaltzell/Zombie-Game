extends Area2D

@export var slot_data: SlotData

@onready var sprite_2d = $Sprite2D

var can_be_picked_up: bool

func _ready():
	sprite_2d.texture = slot_data.item_data.texture
	can_be_picked_up = false


func _physics_process(_delta):
	pass

func _on_body_entered(body):
	if body.inventory_data.pick_up_slot_data(slot_data):
		queue_free()
	
