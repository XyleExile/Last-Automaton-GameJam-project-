extends StaticBody2D

@onready var door_room_1: CollisionShape2D = $door_room_1

var button_connected: bool = false  # Track if button was connected

func _process(delta):
	if not button_connected:
		print("Door")
		var button = get_parent().get_node("Button_Map_1")  # Safer way to check
		if button:
			print("Door Connected")
			button.connect("button_pressed", Callable(self, "open_door"))
			button_connected = true  # Prevent multiple connections

func open_door():
	door_room_1.set_deferred("disabled", true)
	print("Door Opened!")
