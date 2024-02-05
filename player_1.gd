extends CharacterBody2D

# import game
const Game = preload("res://src/game.gd")
# some consts
const SPEED = 100

var main
var game

func _physics_process(delta):
	game.update_platforms(delta)

# Called when the node enters the scene tree for the first time.
func _ready():
	# register _main_ready()
	main = get_tree().get_root().get_node("Main")
	main.connect("main_ready", _main_ready)
	# init game class
	game = Game.new(main, SPEED)

func _main_ready():
	game.register_platform("res://Platforms/dirt3-1.tscn", 0, 0)
