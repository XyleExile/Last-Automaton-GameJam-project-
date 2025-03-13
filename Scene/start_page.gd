extends Control

# Called when the node enters the scene tree for the first time
func _ready():
	# Connect the start button signal if it exists
	if has_node("StartButton"):
		$StartButton.connect("pressed", _on_start_button_pressed)
	
	# Connect the quit button signal if it exists
	if has_node("QuitButton"):
		$QuitButton.connect("pressed", _on_quit_button_pressed)

# Start button pressed
func _on_start_button_pressed():
	# Access the GameManager to start the game
	if get_node("/root/GameManager"):
		get_node("/root/GameManager").start_game()

# Quit button pressed
func _on_quit_button_pressed():
	# Access the GameManager to quit the game
	if get_node("/root/GameManager"):
		get_node("/root/GameManager").quit_game() 
