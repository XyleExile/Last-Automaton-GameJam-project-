extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var tilemap: TileMap = $"../../TileMap"  # Adjust path if needed

# Exported variables for per-instance customization
@export var door_start: Vector2i
@export var door_end: Vector2i
@export var door_layer: int = 1  # Default to laser layer

@export var door_collision: CollisionShape2D  # Editable door collision reference

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
	if sprite_2d.frame == 0:
		sprite_2d.frame = 1
	interactable.is_interactable = false
	print("Button Pressed.")

	# Remove door tiles for THIS button
	open_door()

	# Disable door collision (each button controls a different door)
	if door_collision:
		door_collision.set_deferred("disabled", true)
		print("Door collision disabled!")

func open_door():
	for x in range(door_start.x, door_end.x + 1):
		var tile_pos = Vector2i(x, door_start.y)
		tilemap.set_cell(door_layer, tile_pos, -1)  # Remove the door tile
	print("Door removed from:", door_start, "to", door_end)
