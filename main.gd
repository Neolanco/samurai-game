extends Node2D

signal main_ready

# Called when the node enters the scene tree for the first time.
func _ready():
	# call _main_ready in player_1 or other classes
	emit_signal("main_ready")

func close_game():
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://titlescreen.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	close_game()
	
