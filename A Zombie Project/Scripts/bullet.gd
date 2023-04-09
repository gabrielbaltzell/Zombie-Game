extends CharacterBody2D

signal hit

@export var speed = 1400

var impact_vector
var damage = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func start(_position, _rotation):
	position = _position
	rotation = _rotation
	velocity = Vector2(speed, 0).rotated(rotation)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.get_collider().has_method('_take_damage'):
			collision.get_collider()._take_damage(damage, global_position, global_rotation)
		queue_free()
		

