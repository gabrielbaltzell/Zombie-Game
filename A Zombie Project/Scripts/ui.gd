extends CanvasLayer

@onready var texture_progress_bar = $HealthBar/TextureProgressBar
@onready var player = $"../player"
@onready var menu = $Menu

@export var health_value: int = 0

func _ready():
	texture_progress_bar.value = 100
	player.update_health_bar.connect(update_health_bar_texture)
	player.game_over.connect(on_game_over)

func _process(delta):
	pass

func update_health_bar_texture(_value: int):
	texture_progress_bar.value = _value
	print('updated')
	
func on_game_over():
	menu.visible = true
	
func _on_restart_game_button_pressed():
	Global.restart_game()
