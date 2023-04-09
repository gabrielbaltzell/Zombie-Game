extends Node2D

@onready var marker_2d = $Marker2D
@onready var timer = $Timer

@export var zombie: bool
@export var respawn: bool = false
@export var respawn_freq: float

var zombie_scene = preload("res://Scenes/zombie.tscn")

var mob_array: Array

func _ready():
	timer.wait_time = respawn_freq
	mob_array = [['zombie', zombie, zombie_scene]]
	var index: int = -1
	
	for arrays in mob_array:
		index += 1
		if mob_array[index][1] == false:
			mob_array.pop_at(index)
		var indexindex: String = '[' + var_to_str(index) + ']' + '[' + var_to_str(arrays.find('zombie')) + ']'
	
	if mob_array.size() != 0:
		spawn(process_spawn())
	
	if respawn:
		timer.start()
	
func process_spawn() -> int:
	if mob_array.size() < 1:
		var random_index: int = randi() % (mob_array.size() - 1)
		return random_index
	else: 
		return 0
	
func spawn(mob_index: int):
	var mob = mob_array[mob_index][2].instantiate()
	mob.global_position = marker_2d.global_position
	get_parent().add_child.call_deferred(mob)

func _on_timer_timeout():
	spawn(process_spawn())
