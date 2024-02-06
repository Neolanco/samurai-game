class_name Game

const Platform = preload("res://src/platform.gd")

# consts
const JUMP_DISTANCE = Vector2(300, 100)
const MIN_JUMP_DISTANCE = Vector2(100.0, 10.0)
const RANDOM_JUMP_DISTANCE = false

var _loaded_platforms: Array[Node2D]
var _aviable_platforms: Array[Platform]
var _rng: RandomNumberGenerator
var _main
var _player
var _start_pos # player start_pos
# platform init_pos
# var _init_pos const 0 0

var _velocity: Vector2
var _last_node: TileMap
var _last_pos: Vector2

func _init(main: Node2D, player: CharacterBody2D, start_pos: Vector2):
	_main = main
	_player = player
	_start_pos = start_pos
	
	_rng = RandomNumberGenerator.new()
	_rng.randomize()

func init_platforms():
	for i in 10:
		generate_platform()

func clear_platforms():
	for platform in _loaded_platforms.duplicate():
		_loaded_platforms.erase(platform)
		_main.remove_child(platform)
		platform.queue_free()
		_last_node = null

func get_random_jump_vector():
	var x
	var y
	
	if !RANDOM_JUMP_DISTANCE:
		x = JUMP_DISTANCE.x
		y = JUMP_DISTANCE.y
	else:
		# generate random numbers
		x = _rng.randi_range(MIN_JUMP_DISTANCE.x, JUMP_DISTANCE.x)
		y = _rng.randi_range(MIN_JUMP_DISTANCE.y, JUMP_DISTANCE.y)
	
	# shoudt platform be below or above
	if _rng.randf() > 0.5:
		y = -y
		
	return Vector2(x, y)

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
		node.global_position += get_random_jump_vector()
		
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
	# clone pos so that is is equal in the whole tick and dont change
	var pos = Vector2(_player.global_position.x, _player.global_position.y)
	
	# must be before generate_platform and offset must be less than generate_platform
	if pos.y > _last_node.global_position.y + 1200:
		kill_player()
	
	for platform in _loaded_platforms.duplicate():
		# must be after kill_player anf offset must be more than kill_player
		if platform.global_position.x < pos.x - 1000 || platform.global_position.y < pos.y - 1000 || platform.global_position.y > pos.y + 1000:
			if platform != _last_node:
				_loaded_platforms.erase(platform)
				_main.remove_child(platform)
				platform.queue_free()
				generate_platform()

func kill_player():
	_player.global_position = _start_pos
	clear_platforms()
	init_platforms()
