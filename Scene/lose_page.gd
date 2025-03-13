extends Control

# Called when the node enters the scene tree for the first time
func _ready():
	# Connect the restart button signal if it exists
	if has_node("RestartButton"):
		$RestartButton.connect("pressed", _on_restart_button_pressed)
	
	# Connect the main menu button signal if it exists
	if has_node("MainMenuButton"):
		$MainMenuButton.connect("pressed", _on_main_menu_button_pressed)
	
	# Connect the quit button signal if it exists
	if has_node("QuitButton"):
		$QuitButton.connect("pressed", _on_quit_button_pressed)

# Restart button pressed
func _on_restart_button_pressed():
	# Access the GameManager to restart the game
	if get_node("/root/GameManager"):
		get_node("/root/GameManager").restart_game()

# Main menu button pressed
func _on_main_menu_button_pressed():
	# Access the GameManager to go back to the start scene
	if get_node("/root/GameManager"):
		get_node("/root/GameManager").goto_start_scene()

# Quit button pressed
func _on_quit_button_pressed():
	# Access the GameManager to quit the game
	if get_node("/root/GameManager"):
		get_node("/root/GameManager").quit_game() 
