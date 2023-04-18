extends CharacterBody2D

signal toggle_inventory
signal update_health_bar(health_bar_value: int)
signal game_over

@onready var interact_ray = $InteractRay
@onready var area_2d = $Area2D

@export var inventory_data: InventoryData

const bullet = preload("res://Scenes/bullet.tscn")
const grenade = preload("res://Scenes/grenade.tscn")

@export var speed = 400

const MAX_HITPOINTS: int = 400

var controls_locked: bool = false

var min_interpo = 0.4
var t = min_interpo
var duration = 1
var current_hitpoints: int = 400

var camera_pos

func _ready():
	PlayerManager.player = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector2.ZERO
	var input_vector = Vector2.ZERO
	if controls_locked == false:
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
		if Input.is_action_just_pressed('throw'):
			throw()
			
		look_at(get_global_mouse_position())
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
	
	

func shoot():
	var b = bullet.instantiate()
	b.start($Muzzle.global_position, rotation)
	get_tree().root.add_child(b)
		
func interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()
		
func get_drop_position() -> Vector2:
	var direction = interact_ray.global_transform.x
	print(direction)
	return global_position +  (100 * direction)

func heal(heal_value: int) -> void:
	current_hitpoints += heal_value
	update_health_bar.emit(100 * current_hitpoints/MAX_HITPOINTS)

func damage_received(received_damage: int):
	current_hitpoints -= received_damage
	update_health_bar.emit(100 * current_hitpoints/MAX_HITPOINTS)
	
func throw():
	var g = grenade.instantiate()
	get_tree().root.add_child(g)
	g.start($Shoulder.global_position, global_transform.orthonormalized().x)
	
func _take_damage(damage, _impact_position, _impact_direction):
	damage_received(damage)
	if current_hitpoints <= 0:
		death()

func death():
	controls_locked = true
	emit_signal('game_over')
	


func _on_area_2d_body_entered(body):
	print(body)
