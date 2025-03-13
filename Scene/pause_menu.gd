extends Control

@onready var player = $"."

# Called when the node enters the scene tree for the first time
func _ready():
	# Center the pause menu on the screen
	center_on_screen()
	
	# Make sure this control captures input events
	set_process_input(true)

# Center the pause menu on the screen
func center_on_screen():
	# Get the viewport size
	var viewport_size = get_viewport_rect().size
	
	# Set the position to center the menu
	position = (viewport_size - size) / 2

# Override _input to prevent input from passing through to the game
func _input(event):
	# Consume all input events when the pause menu is active
	if event is InputEvent:
		get_viewport().set_input_as_handled()
		
	# Allow ESC key to close the menu
	if event.is_action_pressed("pause"):
		# Find the player node and call its pauseMenu function
		var player = get_node("/root/map/Player")
		if player and player.has_method("pauseMenu"):
			player.pauseMenu()
		get_viewport().set_input_as_handled()

func _on_resume_pressed() -> void:
	player.pauseMenu()


func _on_quit_pressed() -> void:
	get_tree().quit()
