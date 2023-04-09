extends RigidBody2D

@onready var collision_shape_2d = $CollisionShape2D

func make_room(_pos: Vector2i, _size):
	position = _pos
	var size = _size
	var rectangle_collsion_shape = RectangleShape2D.new()
	collision_shape_2d.shape = rectangle_collsion_shape
	rectangle_collsion_shape.size = size
	
