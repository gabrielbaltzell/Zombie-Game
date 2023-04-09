extends RigidBody2D

signal hit(damage: int)
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var sprite_2d = $Sprite2D
@onready var grenade = $"."
@onready var cpu_particles_2d = $CPUParticles2D
@onready var particle_timer = $CPUParticles2D/ParticleTimer
@onready var explosion = $Explosion
@onready var timer = $Timer
@export var speed = 600

var damage = 100
var impact_vector

func _ready():
	lock_rotation = true
	animated_sprite_2d.visible = false

func start(_position, _rotation):
	position = _position
	rotation = 0
	apply_impulse(speed * _rotation, _position)
	lock_rotation = false
	timer.start()

func _on_timer_timeout():
	sprite_2d.visible = false
	cpu_particles_2d.emitting = true
	animated_sprite_2d.visible = true
	animated_sprite_2d.play("explode")
	particle_timer.start()
	process_damage()
		

func _on_particle_timer_timeout():
	grenade.queue_free()

func process_damage():
	if explosion.get_overlapping_bodies().size() > 0:
		var bodies = explosion.get_overlapping_bodies()
		for abody in bodies:
			if abody.has_method('_take_damage'):
				var rotation_to_abody = (abody.global_position - global_position).angle()
				abody._take_damage(damage, global_position, rotation_to_abody)

