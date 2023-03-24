extends Area2D

@onready var collision_shape_2d = $CollisionShape2D
@export_file('*.tscn') var target_scene_path: String
var root
var current_scene
# Called when the node enters the scene tree for the first time.
func _ready():
	root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func check_bodies(bodies):
	for abody in bodies:
		if abody.is_in_group('Player') && Global.player_just_moved == false:
			Global.go_to_scene(target_scene_path)
			Global.player_just_moved = true
		else:
			Global.player_just_moved = false


func _on_body_entered(body):
	if self.has_overlapping_bodies():
		var bodies = get_overlapping_bodies()
		check_bodies(bodies)

func _on_body_exited(body):
	var bodies = get_overlapping_bodies()
	if bodies.size() == 0:
		Global.player_just_moved = false
