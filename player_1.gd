extends CharacterBody2D

@onready
var main = get_tree().get_root().get_node("Main")

var dirt3_1

func spawn_dirt3_1():
	var dirt3_1 = load("res://Platforms/dirt3-1.tscn").instantiate()
	dirt3_1.global_position = Vector2(0, 0)
	main.add_child(dirt3_1)
	return dirt3_1

func _physics_process(delta):
	if dirt3_1:
		var x = dirt3_1.global_position.x
		var y = dirt3_1.global_position.y
		x += 1
		dirt3_1.global_position = Vector2(x, y)

# Called when the node enters the scene tree for the first time.
func _ready():
	main.connect("main_ready", _main_ready)

func _main_ready():
	dirt3_1 = spawn_dirt3_1()
