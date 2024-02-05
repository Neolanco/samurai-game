class_name Game

var _platsforms: Array[Node2D]
var _main
var _speed

func _init(main: Node2D, speed: float):
	_main = main
	_speed = speed

func register_platform(platform: String, x: float, y: float):
	var node = load(platform).instantiate()
	node.global_position = Vector2(x, y)
	_platsforms.append(node)
	_main.add_child(node)

func update_platforms(delta):
	for platform in _platsforms:
		platform.global_position.x += _speed * delta
