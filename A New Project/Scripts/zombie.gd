extends CharacterBody2D

var target_pos 
@onready var nav_agent = $NavigationAgent2D
@onready var target = get_parent().get_node("player").global_position
@onready var raycast = $RayCast2D

var max_hitpoints = 400
var current_hitpoints

var speed = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	current_hitpoints = max_hitpoints
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	
	call_deferred('actor_setup')
	
func actor_setup():
	await get_tree().physics_frame
	
	reset_target_position(target)
	
func _physics_process(delta):
	if nav_agent.is_navigation_finished():
		reset_target_position(target)
		
	var current_agent_position : Vector2 = global_transform.origin
	var next_path_position : Vector2 = nav_agent.get_next_path_position()
	
	look_at(next_path_position)
	
	var new_velocity : Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * speed
	
	target = get_parent().get_node("player").global_position
	
	var raycasts = get_tree().get_nodes_in_group('raycasts')
	for araycast in raycasts:
		if araycast.is_colliding() and araycast.get_collider() == TileMap:
			wall_avoidence(araycast, new_velocity)
			break
		else:
			movement(new_velocity)
			break
	


func _take_damage(damage):
	current_hitpoints -= damage
	print(current_hitpoints)
	if current_hitpoints <= 0:
		death()

func death():
	queue_free()
	
func reset_target_position(target):
	nav_agent.target_position = target
	
func wall_avoidence(raycast, new_velocity):
	var ray_vector : Vector2 = raycast.global_position - raycast.get_collision_point()
	var ray_vector_reflection : Vector2 = raycast.get_collision_normal().normalized().reflection(ray_vector)
	set_velocity(new_velocity + ray_vector_reflection)
	move_and_slide()
	

func movement(new_velocity):
	set_velocity(new_velocity)
	move_and_slide()
	
