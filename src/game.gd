class_name Game

var _platsforms: Array[Node2D]
var _main
var _speed

var _velocity: Vector2

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
		platform.global_position += _speed * delta * _velocity

func move(x: int, y: int):
	if (abs(x) != 1 && x != 0) || (abs(y) != 1 && y != 0):
		push_error("x and y must be 1 -1 or 1")
		return
	
	_velocity = Vector2(x, y)
