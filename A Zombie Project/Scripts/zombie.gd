extends CharacterBody2D

var blood_splatter = preload("res://Scenes/blood_splatter.tscn")

@onready var nav_agent = $NavigationAgent2D
@onready var target = get_parent().get_node("player").global_position
@onready var raycast = $RayCast2D
@onready var damage_area = $DamageArea
@onready var attack_cooldown_timer = $AttackCooldownTimer

var target_pos 
var max_hitpoints = 400
var current_hitpoints
var attack_damage = 100
var attack_cooldown: float = 1
var attack_cooldown_complete: bool = false

var speed = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	current_hitpoints = max_hitpoints
	attack_cooldown_timer.wait_time = attack_cooldown
	
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	
	call_deferred('actor_setup')
	
	attack_cooldown_timer.start()
	
func actor_setup():
	await get_tree().physics_frame
	
	reset_target_position(target)
	
func _physics_process(_delta):
	if nav_agent.is_navigation_finished():
		reset_target_position(target)
		
	var current_agent_position : Vector2 = global_transform.origin
	var next_path_position : Vector2 = nav_agent.get_next_path_position()
	
	look_at(next_path_position)
	
	var new_velocity : Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * speed
	
	if get_parent().get_node('player'):
		target = get_parent().get_node("player").global_position
	else:
		target = get_parent().get_node('MobSpawner').global_position
	
	var raycasts = get_tree().get_nodes_in_group('raycasts')
	for araycast in raycasts:
		if araycast.is_colliding() and araycast.get_collider() == TileMap:
			wall_avoidence(araycast, new_velocity)
			break
		else:
			movement(new_velocity)
			break
	
func _process(delta):
	if damage_area.has_overlapping_bodies():
		var bodies = damage_area.get_overlapping_bodies()
		deal_damage(bodies)

func _take_damage(damage, impact_position, impact_direction):
	current_hitpoints -= damage
	print(current_hitpoints)
	instantiate_blood_splatter(impact_position, impact_direction)
	if current_hitpoints <= 0:
		death()

func death():
	queue_free()
	
func reset_target_position(_target):
	nav_agent.target_position = _target
	
func wall_avoidence(_raycast, new_velocity):
	var ray_vector : Vector2 = _raycast.global_position - _raycast.get_collision_point()
	var ray_vector_reflection : Vector2 = _raycast.get_collision_normal().normalized().reflection(ray_vector)
	set_velocity(new_velocity + ray_vector_reflection)
	move_and_slide()
	

func movement(new_velocity):
	set_velocity(new_velocity)
	move_and_slide()
	
func instantiate_blood_splatter(impact_position, impact_direction):
	var blood_splatter_instance = blood_splatter.instantiate()
	blood_splatter_instance.rotation = impact_direction + deg_to_rad(90)
	blood_splatter_instance.position = global_position
	get_parent().find_child('Debris').add_child(blood_splatter_instance)

func get_blood_splatter_position(impact_position, impact_direction) -> Vector2:
	var impact_vector: Vector2
	impact_vector = Vector2(impact_direction, impact_position)
	return impact_vector
	
func deal_damage(bodies_in_damage_area):
	for abody in bodies_in_damage_area:
			if abody.has_method('_take_damage') and abody.is_in_group('Player') \
					and attack_cooldown_complete == true:
				abody._take_damage(attack_damage, global_position, global_rotation)
				attack_cooldown_complete = false
				attack_cooldown_timer.start()

func _on_attack_cooldown_timer_timeout():
	attack_cooldown_complete = true
