extends CharacterBody2D

# some consts
# y
const JUMP_VELOCITY = -900.0
const AIR_JUMP_VELOCITY = -600.0
const GRAVITY = 2400
# x
const MAX_VELOCITY = Vector2(700, 1000)
const ACCELERATION = 60.0
const SLIDE = 0.2 # between 0 and 1
# other
const JUMP_AFTER_PLATFORM = 0.1
const SCORE_FACTOR = 0.002

var main
var game
var floating_seconds: float = 0.0
var jump_hold = false
var score: int = 0
var high_score: int = 0
var time: float = 0
@onready
var sprites = [$Sprite_Idle, $Sprite_Walking, $Sprite_Jump, $Sprite_Run]
var is_jumping_since: float = 0

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
		
	if abs(velocity.x) < MAX_VELOCITY.x:
		velocity.x += move.x * (ACCELERATION ** 2) * delta

func add_move_y(move, delta):
	# set floating_seconds
	if is_on_floor():
		floating_seconds = 0.0
	else:
		floating_seconds += delta
	
	# check if jump pressed
	if move.y != -1:
		jump_hold = false
		return
	
	if floating_seconds < JUMP_AFTER_PLATFORM:
		# don't jump if jump was kept presed
		if jump_hold:
			return
		jump_hold = true
		
		# velocity fixed
		velocity.y = JUMP_VELOCITY
	else:
		# longer jump
		velocity.y += AIR_JUMP_VELOCITY * delta

	# because just jumped
	floating_seconds = 10 ** 18

func flip_player():
	$"Sprite_Idle".flip_h = velocity.x < 0
	$"Sprite_Walking".flip_h = velocity.x < 0
	$"Sprite_Death".flip_h = velocity.x < 0
	$"Sprite_Jump".flip_h = velocity.x < 0

func update_score(delta):
	time += delta
	if $".".global_position.x * SCORE_FACTOR > score:
		score = int($".".global_position.x * SCORE_FACTOR)
		if score > high_score:
			high_score = score
	$Camera2D2/ScoreLabel.text = "High-Score: " + str(high_score) + "\nScore: " + str(score) + "\n Time: " + str(int(time)) + " sec"

var last_pos = Vector2(0, 0)
func print_pos():
	if $".".global_position != last_pos:
		last_pos = $".".global_position
		print("playerpos x: " + str($".".global_position.x) + ", y: " + str($".".global_position.y))

func start_animation(sprite):
	if sprite.is_playing():
		return
	for s in sprites:
		s.visible = false
		s.stop()
	sprite.visible = true
	sprite.play()

func add_animation(delta):
	is_jumping_since += delta
	if !is_on_floor():
		start_animation($Sprite_Jump)
		is_jumping_since = 0
		return
	
	if is_jumping_since < 0.1:
		return
	
	# Changes the animation based on velocity
	if abs(velocity.x) > 0:
		if $Sprite_Walking.is_visible() || $Sprite_Run.is_visible():
			pass
		elif abs(velocity.x) == (MAX_VELOCITY.x):
			start_animation($Sprite_Run)
		else:
			start_animation($Sprite_Walking)
		return
		
	if $Sprite_Idle.is_visible():
		pass
	else:
		start_animation($Sprite_Idle)

func _physics_process(delta):
	var move = read_user_input()
	add_move_x(move, delta)
	add_move_y(move, delta)
	
	flip_player()
	
	add_gravity(delta)
	move_and_slide()
	
	game.update(delta)
	
	add_animation(delta)
	
	update_score(delta)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# register _main_ready()
	main = get_tree().get_root().get_node("Main")
	main.connect("main_ready", _main_ready)
	# init game ass
	game = Game.new(main, $".")
	# hide mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _main_ready():
	game.register_platform("res://platforms/smb1-1.tscn", 0.001)
	game.register_platform("res://platforms/dirt6-1.tscn", 1)
	game.register_platform("res://platforms/dirt5-1.tscn", 1)
	game.register_platform("res://platforms/dirt4-1.tscn", 1)
	game.register_platform("res://platforms/dirt3-1.tscn", 1)
	game.register_platform("res://platforms/dirt2-1.tscn", 1)
	game.register_platform("res://platforms/dirt1-1.tscn", 1)
	game.init_platforms()
	$".".global_position = Vector2(0, 0)
