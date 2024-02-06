extends CharacterBody2D

# import game
const Game = preload("res://src/game.gd")
# some consts
const ACCELERATION = 30.0
const JUMP_VELOCITY = -300.0
const AIR_JUMP_VELOCITY = -200.0
const MAX_VELOCITY = Vector2(500, 1000)
const SLIDE = 0.2 # between 0 and 1
const GRAVITY = 800
const START_POS = Vector2(90, -200)

var main
var game

func read_user_input():
	var move = Vector2i(0, 0)
	if Input.is_key_pressed(KEY_W) || Input.is_key_pressed(KEY_UP) || Input.is_key_pressed(KEY_SPACE):
		move.y -= 1
	if Input.is_key_pressed(KEY_A) || Input.is_key_pressed(KEY_LEFT):
		move.x -= 1
	if Input.is_key_pressed(KEY_S) || Input.is_key_pressed(KEY_DOWN) || Input.is_key_pressed(KEY_SHIFT) || Input.is_key_pressed(KEY_Q):
		move.y += 1
	if Input.is_key_pressed(KEY_D) || Input.is_key_pressed(KEY_RIGHT):
		move.x += 1
	return move

func add_gravity(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func add_move_x(move, delta):
	if move.x == 0:
		if abs(velocity.x) < (ACCELERATION ** 2) * delta:
			velocity.x = 0
			return
		if velocity.x > 0:
			velocity.x -= (ACCELERATION ** 2) * delta
		elif velocity.x < 0:
			velocity.x += (ACCELERATION ** 2) * delta
		return
		
	if velocity.x < MAX_VELOCITY.x:
		velocity.x += move.x * (ACCELERATION ** 2) * delta

func add_move_y(move, delta):
	if move.y == -1:
		if is_on_floor():
			# velocity fixed
			velocity.y += JUMP_VELOCITY
		else:
			velocity.y += AIR_JUMP_VELOCITY * delta

func flip_player():
	$"Sprite_Idle".flip_h = velocity.x < 0
	$"Sprite_Walking".flip_h = velocity.x < 0
	$"Sprite_Death".flip_h = velocity.x < 0
	$"Sprite_Jump".flip_h = velocity.x < 0

func _physics_process(delta):
	var move = read_user_input()
	add_move_x(move, delta)
	add_move_y(move, delta)
	
	flip_player()
	
	add_gravity(delta)
	move_and_slide()
	
	game.update(delta)

# Called when the node enters the scene tree for the first time.
func _ready():
	# register _main_ready()
	main = get_tree().get_root().get_node("Main")
	main.connect("main_ready", _main_ready)
	# init game class
	game = Game.new(main, $".", START_POS)
	game.set_jump_distance(MAX_VELOCITY.x, JUMP_VELOCITY, AIR_JUMP_VELOCITY, GRAVITY)

func _main_ready():
	game.register_platform("res://Platforms/dirt3-1.tscn")
	game.init_platforms()
	$".".global_position = START_POS
