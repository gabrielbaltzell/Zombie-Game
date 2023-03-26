extends CharacterBody2D

signal toggle_inventory

@onready var interact_ray = $InteractRay

@export var inventory_data: InventoryData

@onready var bullet = preload("res://Scenes/bullet.tscn")

@export var speed = 400

var min_interpo = 0.4
var t = min_interpo
var duration = 1

var camera_pos

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector2.ZERO
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
		
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
		#Emits to main.gd
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit() 
		
	if Input.is_action_just_pressed("interact"):
		interact()
		
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		if t < duration:
			t += delta
		velocity = velocity.lerp(input_vector, t) * speed
	if input_vector.length() == 0:
		t = min_interpo
	move_and_collide(velocity * delta)
	
	look_at(get_global_mouse_position())

func shoot():
	var b = bullet.instantiate()
	b.start($Muzzle.global_position, rotation)
	get_tree().root.add_child(b)
		
func interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()
