extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

# Win button properties
@export var win_scene_path: String = "res://Scene/game_win.tscn"

func _ready() -> void:
	interactable.interact = _on_interact
	
	# The interactable properties are already set in the scene file
	# interact_name = "Win Game" is set in the scene

func _on_interact():
	print("Win Button Pressed!")
	
	# Change sprite frame to show button pressed (if using the same spritesheet as regular button)
	sprite_2d.frame = 1
	
	# Disable further interaction
	interactable.is_interactable = false
	
	# Transition to the win scene after a short delay
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(win_scene_path)
	
	# Return true to signal the interaction is complete
	return true 
