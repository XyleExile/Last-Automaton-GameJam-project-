extends Camera2D

@onready var player: CharacterBody2D = $"../Player"
@onready var current_camera: Camera2D = $"."
@onready var map: Node2D = $".."

var edge_margin: float = 10  # Distance from the edge where camera switch triggers
var switch_cooldown: float = 10  # Cooldown time in seconds
var last_switch_time: float = 0.0  # Tracks the last time a switch happened

# Timer for cooldown (prevents multiple switches)
var switch_timer: Timer = Timer.new()
var can_switch: bool = true  # Cooldown flag

func _reset_switch():
	can_switch = true  # Reset cooldown flag
	
func _ready() -> void:
	current_camera.make_current()
	# Set up switch cooldown timer
	switch_timer.wait_time = 1.0  # 1 second cooldown
	switch_timer.one_shot = true
	switch_timer.timeout.connect(_reset_switch)
	add_child(switch_timer)
	
func _process(delta: float):
	if !current_camera.is_current() or !can_switch:
		return 

	var screen_size = get_viewport_rect().size  # Correctly get screen size
	var camera_position = current_camera.get_screen_center_position()  # Camera center position

	# Calculate camera edges
	var left_edge = camera_position.x - screen_size.x / 2 + edge_margin
	var right_edge = camera_position.x + screen_size.x / 2 - edge_margin
	var top_edge = camera_position.y - screen_size.y / 2 + edge_margin
	var bottom_edge = camera_position.y + screen_size.y / 2 - edge_margin

	# Check if enough time has passed since last switch
	if player.position.x < left_edge or player.position.x > right_edge or \
	player.position.y < top_edge or player.position.y > bottom_edge:
		switch_camera()

func switch_camera():
	var target_camera = find_nearest_camera()
	print(target_camera)
	if target_camera and !target_camera.is_current():
		target_camera.make_current()
		last_switch_time = Time.get_ticks_msec()  # Update cooldown timer
		print("Camera switched to: ", target_camera.name)

func find_nearest_camera() -> Camera2D:
	if not map:
		print("Error: Map node not found!")
		return null

	var cameras = []  # Store valid cameras
	for child in map.get_children():
		if child is Camera2D and child != current_camera:
			cameras.append(child)

	if cameras.is_empty():
		print("No cameras found in Node2D Map!")
		return null

	# Find the closest camera to the player
	var nearest_camera = null
	var min_distance = INF

	for cam in cameras:
		var distance = player.position.distance_to(cam.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_camera = cam

	return nearest_camera
