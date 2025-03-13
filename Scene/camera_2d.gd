extends Camera2D

@onready var main_camera: Camera2D = self  # Correctly define main_camera

func _ready():
	main_camera.make_current()  # Now this will work

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
