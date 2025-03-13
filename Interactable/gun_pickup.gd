extends Area2D

@export var interact_name: String = "Pick up Gun"
@export var is_interactable: bool = true

@export var tilemap: TileMap  # Reference to the TileMap (set in Inspector)
@export var door_start: Vector2i  # Top tile of the door (set in Inspector)
@export var door_end: Vector2i  # Bottom tile of the door (set in Inspector)
@export var door_layer: int = 1  # Laser layer index (set in Inspector)
@export var door_collision: CollisionShape2D  # Collision shape to disable (set in Inspector)

var interact: Callable = func():
	# Get the player node
	var player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player").size() > 0 else null
	
	# If player is found, give them the gun
	if player and player.has_method("collect_gun"):
		player.collect_gun()
		
		# Remove the vertical door
		remove_door()
		
		# Play pickup sound if available
		if has_node("PickupSound"):
			$PickupSound.play()
			await $PickupSound.finished  # Wait for sound to finish before removing
		
		# Remove the pickup from the scene
		queue_free()
	
	return true  # Interaction completed successfully

func _ready():
	# Ensure collision is set correctly
	collision_layer = 2  # Same as other interactables
	collision_mask = 0   # Don't detect collisions with other objects

func remove_door():
	if tilemap:
		for y in range(door_start.y, door_end.y + 1):  # Loop through Y instead of X
			var tile_pos = Vector2i(door_start.x, y)  # Keep X fixed, move Y
			tilemap.set_cell(door_layer, tile_pos, -1)  # Remove tile from laser layer

		print("Vertical laser door removed from:", door_start, "to", door_end)

	# Disable the assigned collision shape
	if door_collision:
		door_collision.set_deferred("disabled", true)
		print("Door collision disabled!")
