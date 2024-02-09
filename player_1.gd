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
var last_score: int = 0
var high_score: int = 0
var time: float = 0
var is_jumping_since: float = 0
var can_move = true
var health: int = 3
var sprites = []
var sprite_idle
var sprite_walking
var sprite_jump
var sprite_run
var is_new_charakter = false
var sprite_timeout: float = 0

func read_user_input():
	var move = Vector2i(0, 0)
	if !can_move:
		return move
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
	for s in sprites:
		if velocity.x != 0.0:
			s.flip_h = velocity.x < 0

func update_score(delta):
	time += delta
	if $".".global_position.x * SCORE_FACTOR > score:
		score = int($".".global_position.x * SCORE_FACTOR)
		if score + last_score > high_score:
			high_score = score + last_score
	$Camera2D2/ScoreLabel.text = "High-Score: " + str(high_score) + "\nScore: " + str(score + last_score) + "\n Time: " + str(int(time)) + " sec"

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
		start_animation(sprite_jump)
		is_jumping_since = 0
		return
	
	if is_jumping_since < 0.1:
		return
	
	# Changes the animation based on velocity
	if abs(velocity.x) > 0:
		if sprite_walking.is_visible() || sprite_run.is_visible():
			pass
		elif abs(velocity.x) == (MAX_VELOCITY.x):
			start_animation(sprite_run)
		else:
			if abs(velocity.x) > 400:
				start_animation(sprite_run)
			else:
				start_animation(sprite_walking)
		return
		
	if sprite_idle.is_visible():
		pass
	else:
		start_animation(sprite_idle)

func update_health():
	$"HealthLabel".text = str(health)

func _physics_process(delta):
	var move = read_user_input()
	add_move_x(move, delta)
	add_move_y(move, delta)
	
	flip_player()
	
	add_gravity(delta)
	move_and_slide()
	
	game.update(delta)
	
	add_animation(delta)
	
	#print_pos()
	
	update_score(delta)
	update_health()
	
	sprite_timeout += delta
	if Input.is_key_pressed(KEY_C) && sprite_timeout < 10:
		sprite_timeout = 0
		is_new_charakter = !is_new_charakter
		update_sprites()

func update_sprites():
	if sprites.size() > 0:
		for s in sprites:
			s.visible = false
	if is_new_charakter:
		sprite_idle = $Sprite_Idle_Samurai
		sprite_walking = $Sprite_Walking_Samurai
		sprite_jump = $Sprite_Jump_Samurai
		sprite_run = $Sprite_Run_Samurai
	else:
		sprite_idle = $Sprite_Idle
		sprite_walking = $Sprite_Walking
		sprite_jump = $Sprite_Jump
		sprite_run = $Sprite_Run
	sprites = [sprite_idle, sprite_walking, sprite_jump, sprite_run]

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
	update_sprites()

func _main_ready():
	game.register_platform("res://platforms/smb1-1.tscn", 0.1)
	game.register_platform("res://platforms/dirt9_8-1.tscn", 1)
	game.register_platform("res://platforms/dirt9_7-1.tscn", 1)
	game.register_platform("res://platforms/dirt9_6-1.tscn", 1)
	game.register_platform("res://platforms/dirt9_5-1.tscn", 1)
	game.register_platform("res://platforms/dirt9_4-1.tscn", 1)
	game.register_platform("res://platforms/dirt9_3-1.tscn", 1)
	game.register_platform("res://platforms/dirt9_2-1.tscn", 1)
	game.register_platform("res://platforms/dirt9_1-1.tscn", 1)
	game.register_platform("res://platforms/dirt9-1.tscn", 1)
	game.register_platform("res://platforms/dirt8-1.tscn", 1)
	game.register_platform("res://platforms/dirt7-1.tscn", 1)
	game.register_platform("res://platforms/dirt6-1.tscn", 1)
	game.register_platform("res://platforms/dirt5-1.tscn", 1)
	game.register_platform("res://platforms/dirt4-1.tscn", 1)
	game.register_platform("res://platforms/dirt3-1.tscn", 1)
	game.register_platform("res://platforms/dirt2-1.tscn", 1)
	game.register_platform("res://platforms/dirt1-1.tscn", 1)
	game.init_platforms()
	$".".global_position = Vector2(0, 0)
