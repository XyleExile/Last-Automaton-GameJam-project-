extends Node

# Scene paths
const START_SCENE_PATH = "res://Scene/menu.tscn"
const GAME_SCENE_PATH = "res://Scene/map.tscn"
const WIN_SCENE_PATH = "res://Scene/game_win.tscn"
const LOSE_SCENE_PATH = "res://Scene/game_lose.tscn"

# Game state
var current_scene = null
var game_started = false
var player_won = false

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize by loading the start scene
	call_deferred("goto_start_scene")

# Change to the start scene
func goto_start_scene():
	game_started = false
	player_won = false
	change_scene(START_SCENE_PATH)

# Start the game
func start_game():
	game_started = true
	change_scene(GAME_SCENE_PATH)

# Player won the game
func player_win():
	game_started = false
	player_won = true
	change_scene(WIN_SCENE_PATH)

# Player lost the game
func player_lose():
	game_started = false
	player_won = false
	change_scene(LOSE_SCENE_PATH)

# Generic scene change function
func change_scene(scene_path):
	# Get the current scene
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
	# Remove the current scene
	if current_scene:
		current_scene.queue_free()
	
	# Load the new scene
	var new_scene = load(scene_path)
	if new_scene:
		current_scene = new_scene.instantiate()
		# Add it to the tree
		get_tree().root.add_child(current_scene)
		# Set as current scene
		get_tree().current_scene = current_scene
	else:
		print("Error: Could not load scene at path: ", scene_path)

# Restart the current game
func restart_game():
	start_game()

# Quit the game
func quit_game():
	get_tree().quit() 
