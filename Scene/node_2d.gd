extends Node2D

@export var tilemap: TileMap  # Assign the TileMap in Inspector
@export var door_start: Vector2i  # First tile of the door
@export var door_end: Vector2i  # Last tile of the door
@export var door_layer: int = 1  # Laser layer index
@export var door_collision: CollisionShape2D  # Assign the door's collision shape
@export var monsters: Array[CharacterBody2D]  # Manually assign monsters in the Inspector

func _ready():
	# Make sure all assigned monsters reference this room
	for monster in monsters:
		if monster != null:
			monster.room_controller = self  # Let the monster reference this room controller

func monster_died(monster):
	# Remove monster from list
	monsters.erase(monster)
	print("Monster died. Remaining:", monsters.size())

	# If no more monsters remain, remove the door
	if monsters.size() == 0:
		remove_door()

func remove_door():
	if tilemap:
		for x in range(door_start.x, door_end.x + 1):  # Loop through Y for vertical doors
			var tile_pos = Vector2i(x, door_start.y)
			tilemap.set_cell(door_layer, tile_pos, -1)  # Remove the tile

		print("Door removed from:", door_start, "to", door_end)

	if door_collision:
		door_collision.set_deferred("disabled", true)
		print("Door collision disabled!")
