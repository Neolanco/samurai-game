extends Node2D

signal dummy_start_walk

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func close_game():
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	close_game()
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("dummy_start_walk")



func _on_BTNstart_pressed():
	print('BTNstart pressed')
	emit_signal("dummy_start_walk")
	get_tree().change_scene_to_file("res://main.tscn")
