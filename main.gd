extends Node2D

signal main_ready

# Called when the node enters the scene tree for the first time.
func _ready():
	# call _main_ready in player_1 or other classes
	emit_signal("main_ready")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
