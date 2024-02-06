class_name Game

const Platform = preload("res://src/platform.gd")

var _loaded_platforms: Array[Node2D]
var _aviable_platforms: Array[Platform]
var _rng: RandomNumberGenerator
var _main
var _player
# var _init_pos const 0 0

var _velocity: Vector2
var _last_node: TileMap

func _init(main: Node2D, player: CharacterBody2D):
	_main = main
	_player = player
	
	_rng = RandomNumberGenerator.new()
	_rng.randomize()

func init_platforms():
	for i in 10:
		generate_platform()

func generate_platform():
	if _loaded_platforms.size() == 0:
		# load first platform
		var node: TileMap = load(_aviable_platforms[0].platform).instantiate()
		node.global_position = Vector2(0, 0)
		
		# add platform (node)
		_loaded_platforms.append(node)
		_main.add_child(node)
		_last_node = node
	else:
		# load random node
		var index = _rng.randi_range(0, _aviable_platforms.size() - 1)
		var node: TileMap = load(_aviable_platforms[index].platform).instantiate()
		
		# new platform pos without jump
		node.global_position = _get_most_right_position(_last_node) + _last_node.global_position
		
		# apply jump
		# node.global_position.x += 100
		
		# add platform (node)
		_loaded_platforms.append(node)
		_main.add_child(node)
		_last_node = node

func register_platform(platform: String):
	_aviable_platforms.append(Platform.new(platform))

# local
func _get_most_right_position(node: TileMap):
	var max = Vector2i(0, 0)
	for pos in node.get_used_cells(0):
		if pos.x > max.x:
			max = pos
	return node.map_to_local(max) + Vector2(0.5 * node.rendering_quadrant_size, -0.5 * node.rendering_quadrant_size)

func update(delta):
	for platform in _loaded_platforms:
		var pos = _player.global_position
		if platform.global_position.x < pos.x - 1000 || platform.global_position.y < pos.y - 1000:
			if platform != _last_node:
				_loaded_platforms.erase(platform)
				_main.remove_child(platform)
				platform.queue_free()
				generate_platform()
