extends Node2D

signal dummy_start_walk
#@onready var player_dummy = $Player_dummy
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func close_game():
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# print($Player_dummy.global_position)
	close_game()
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("dummy_start_walk")     
	if $Player_dummy.global_position.y > 905:
		get_tree().change_scene_to_file("res://main.tscn") 
	#if $Fallzone.overlaps_body(player_dummy):
		#print('BTNstart pressed')
		#get_tree().change_scene_to_file("res://main.tscn")
		



func _on_BTNstart_pressed():
	print('BTNstart pressed')
	emit_signal("dummy_start_walk")
