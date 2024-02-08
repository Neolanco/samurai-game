class_name Game

# consts
const JUMP_DISTANCE = Vector2(500, 220)
const MIN_JUMP_DISTANCE = Vector2(200.0, 50.0)
const RANDOM_JUMP_DISTANCE = true

var _loaded_platforms: Array[Node2D]
var _aviable_platforms: Array[Platform]
var _rng: RandomNumberGenerator
var _main
var _player

var _last_node: TileMap
var _first_pos: Vector2
var _is_killing: bool = false
var _delay_update: float = 0

func _init(main: Node2D, player: CharacterBody2D):
	_main = main
	_player = player
	
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
	# load random node
	var max_number = 0
	for p in _aviable_platforms:
		max_number += p.proboeirghio3etry
	var random_number = randf_range(0, max_number)
	var platform = _aviable_platforms[0].platform
	var current_p = 0
	for p in _aviable_platforms:
		current_p += p.proboeirghio3etry
		#print("p: " + str(p.proboeirghio3etry) + " max: " + str(max_number) + " random: " + str(random_number) + " current_p: " + str(current_p))
		if random_number < current_p:
			platform = p.platform
			break
	var node: TileMap = load(platform).instantiate()
	
	# new platform pos without jump
	if _last_node:
		node.global_position = _get_most_right_position(_last_node) + _last_node.global_position
	else:
		node = load("res://platforms/start.tscn").instantiate()
		node.global_position = Vector2(-800, 300)
	
	# apply jump
	node.global_position += get_random_jump_vector()
	
	# add platform (node)
	_loaded_platforms.append(node)
	_main.add_child(node)
	_last_node = node
	# print(platform)

func register_platform(platform: String, proboeirghio3etry: float):
	_aviable_platforms.append(Platform.new(platform, proboeirghio3etry))

# local
func _get_most_right_position(node: TileMap):
	var max_cell = Vector2i(0, 0)
	for pos in node.get_used_cells(0):
		if pos.x > max_cell.x:
			if pos.x == max_cell.x:
				if max_cell.y < pos.y:
					max_cell = pos
			else:
				max_cell = pos
	return node.map_to_local(max_cell) + Vector2(0.5 * node.rendering_quadrant_size, -0.5 * node.rendering_quadrant_size)

func update(delta):
	_delay_update += delta
	if _is_killing:
		return
	
	# must be before generate_platform and offset must be less than generate_platform
	if _player.global_position.y > _last_node.global_position.y + 3600:
		kill_player()
	
	if _delay_update < 1:
		return
	_delay_update = 0
	
	# must be after kill_player anf offset must be more than kill_player
	var pos = _player.global_position
	if _first_pos.x < pos.x - 3000 || _first_pos.y < pos.y - 3000 || _first_pos.y > pos.y + 3000:
		var platform = _loaded_platforms.pop_front()
		_main.remove_child(platform)
		platform.queue_free()
		generate_platform()
		_first_pos = _loaded_platforms[0].global_position + _get_most_right_position(_loaded_platforms[0])
		#print("_first_pos x: " + str(_first_pos.x) + ", y: " + str(_first_pos.y))

func kill_player():
	_is_killing = true
	# _player.get_tree().quit()
	_player.global_position = Vector2(0, 0)
	if _player.health <= 0:
		_player.time = 0
		_player.score = 0
	else:
		_player.health -= 1
	_player.velocity = Vector2(0, 0)
	clear_platforms()
	init_platforms()
	_is_killing = false
