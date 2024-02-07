class_name Game

# consts
const JUMP_DISTANCE = Vector2(450, 100)
const MIN_JUMP_DISTANCE = Vector2(200.0, 50.0)
const RANDOM_JUMP_DISTANCE = true

var _loaded_platforms: Array[Node2D]
var _aviable_platforms: Array[Platform]
var _rng: RandomNumberGenerator
var _main
var _player
var _start_pos # player start_pos
# platform init_pos
# var _init_pos const 0 0

var _last_node: TileMap
var _first_pos: Vector2

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
	for i in _loaded_platforms.size():
		var platform = _loaded_platforms.pop_back()
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
		x = _rng.randf_range(MIN_JUMP_DISTANCE.x, JUMP_DISTANCE.x)
		y = _rng.randf_range(MIN_JUMP_DISTANCE.y, JUMP_DISTANCE.y)
	
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
		_first_pos = node.global_position
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
	var max_cell = Vector2i(0, 0)
	for pos in node.get_used_cells(0):
		if pos.x > max_cell.x:
			max_cell = pos
	return node.map_to_local(max_cell) + Vector2(0.5 * node.rendering_quadrant_size, -0.5 * node.rendering_quadrant_size)

func update(_delta):
	# must be before generate_platform and offset must be less than generate_platform
	if _player.global_position.y > _last_node.global_position.y + 1200:
		kill_player()
	
	# must be after kill_player anf offset must be more than kill_player
	var pos = _player.global_position
	if _first_pos.x < pos.x - 1000 || _first_pos.y < pos.y - 1000 || _first_pos.y > pos.y + 1000:
		var platform = _loaded_platforms.pop_front()
		_main.remove_child(platform)
		platform.queue_free()
		generate_platform()
		_first_pos = _loaded_platforms[0].global_position

func kill_player():
	_player.global_position = _start_pos
	# _player.velocity = Vector2(0, 0)
	clear_platforms()
	init_platforms()
