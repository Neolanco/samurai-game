class_name Game

const Platform = preload("res://src/platform.gd")

# consts
const PADDING = Vector2(100.0, 10.0)

var _loaded_platforms: Array[Node2D]
var _aviable_platforms: Array[Platform]
var _rng: RandomNumberGenerator
var _main
var _player
var _start_pos
# var _init_pos const 0 0

var _velocity: Vector2
var _last_node: TileMap
var _jump_distance: Vector2

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
	for platform in _loaded_platforms:
		_loaded_platforms.erase(platform)
		_main.remove_child(platform)
		platform.queue_free()
		_last_node = null
		_loaded_platforms = []

func set_jump_distance(speed: float, jump_velocity: float, air_jump_velocity: float, gravity: float):
	# chat gpt start
	var max_horizontal_distance = speed * (jump_velocity / gravity)
	var max_vertical_distance = (jump_velocity * jump_velocity) / (2 * gravity)
	var max_air_horizontal_distance = speed * (air_jump_velocity / gravity)
	var max_air_vertical_distance = (air_jump_velocity * air_jump_velocity) / (2 * gravity)
	
	var max_x = max(max_horizontal_distance, max_air_horizontal_distance)
	var max_y = max(max_vertical_distance, max_air_vertical_distance)
	# chat gpt end
	
	_jump_distance = Vector2(abs(max_x), abs(max_y))

func get_random_jump_vector():
	# check if _jump_distance is lower than PADDING
	# and if so set it to PADDING
	# x and y independet from each other
	if _jump_distance.x < PADDING.x:
		_jump_distance.x = PADDING.x
	if _jump_distance.y < PADDING.y:
		_jump_distance.y = PADDING.y
	
	# generate random numbers
	var x = _rng.randi_range(PADDING.x, _jump_distance.x)
	var y = _rng.randi_range(PADDING.y, _jump_distance.y)
	
	# shodt platform be below or above
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
	for platform in _loaded_platforms:
		var pos = _player.global_position
		if platform.global_position.x < pos.x - 1000 || platform.global_position.y < pos.y - 1000:
			if platform != _last_node:
				_loaded_platforms.erase(platform)
				_main.remove_child(platform)
				platform.queue_free()
				generate_platform()
	
	if _player.global_position.y > _last_node.global_position.y + 1000:
		kill_player()

func kill_player():
	_player.global_position = _start_pos
	clear_platforms()
	init_platforms()
