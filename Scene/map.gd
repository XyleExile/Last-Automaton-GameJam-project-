extends Node2D

# Variables to track game state
var all_monsters_defeated = false
var player_alive = true
var win_condition_checked = false

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize game state
	all_monsters_defeated = false
	player_alive = true
	win_condition_checked = false

# Called every frame
func _process(delta):
	# Only check win conditions if we haven't already determined the outcome
	if not win_condition_checked:
		check_win_conditions()

# Check if the player has won or lost
func check_win_conditions():
	# Get the player node
	var player = $Player
	if player:
		player_alive = player.alive
	
	# Check if all monsters are defeated
	all_monsters_defeated = are_all_monsters_defeated()
	
	# Win condition: All monsters defeated and player is alive
	if all_monsters_defeated and player_alive:
		win_condition_checked = true
		# Wait a moment before transitioning to win screen
		await get_tree().create_timer(1.0).timeout
		if get_node("/root/GameManager"):
			get_node("/root/GameManager").player_win()

# Check if all monsters have been defeated
func are_all_monsters_defeated():
	# Count the number of monsters in the scene
	var big_monsters = get_tree().get_nodes_in_group("monsters")
	
	# If there are no monsters left, the player has won
	return big_monsters.size() == 0 
