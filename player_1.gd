extends CharacterBody2D

# import game
const Game = preload("res://src/game.gd")
# some consts
const SPEED = 1000

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

func _physics_process(delta):
	game.update(delta)
	var move = read_user_input()
	game.player_input(move.x, move.y)

# Called when the node enters the scene tree for the first time.
func _ready():
	# register _main_ready()
	main = get_tree().get_root().get_node("Main")
	main.connect("main_ready", _main_ready)
	# init game class
	game = Game.new(main, SPEED)

func _main_ready():
	game.register_platform("res://Platforms/dirt3-1.tscn")
	for i in 5:
		game.generate_platform()
