extends Sprite2D

var can_fire: bool = true
var bullet = preload("res://Scene/Bullet.tscn")

@onready var animation_player = get_parent().get_node("AnimationPlayer")
@onready var gunshot_audio = AudioStreamPlayer.new()  # Audio player for gunshot sound

func _ready() -> void:
	set_as_top_level(true)
	
	# Setup gunshot audio
	setup_gunshot_audio()
	
	# Hide the gun initially - player needs to collect it
	visible = false

# Setup the gunshot audio player
func setup_gunshot_audio():
	# Create and configure the audio player
	add_child(gunshot_audio)
	
	# Load the gunshot sound
	var sound = load("res://Audio/gunshot.mp3")
	if sound:
		gunshot_audio.stream = sound
		gunshot_audio.volume_db = -15  # Adjust volume as needed
	else:
		print("Warning: Could not load gunshot audio")

func _process(delta: float) -> void:
	# Only process if the gun is visible (player has it)
	if not visible:
		return
		
	# Check if player has the gun
	if get_parent().has_method("collect_gun") and not get_parent().has_gun:
		return
		
	position.x = lerp(position.x, get_parent().position.x - 12, 0.5)
	position.y = lerp(position.y, get_parent().position.y, 0.5)
	
	var mouse_position = get_global_mouse_position()
	look_at(mouse_position)
	
	if get_global_mouse_position().x > position.x:
		scale.y = 1
	else:
		scale.y = -1
	
	if animation_player.is_playing() and animation_player.current_animation == "up":
		z_index = -1
	elif animation_player.is_playing() and animation_player.current_animation != "up":
		z_index = 1
		
	
	if Input.is_action_pressed("Shoot") and can_fire and visible:
		var bullet_instance = bullet.instantiate()
		bullet_instance.rotation = rotation
		bullet_instance.global_position = $muzzle.global_position
		get_parent().add_child(bullet_instance)
		
		# Play gunshot sound
		play_gunshot_sound()
		
		can_fire = false
		await get_tree().create_timer(0.1).timeout
		can_fire = true

# Play the gunshot sound
func play_gunshot_sound():
	# If the audio is still playing, stop it and restart
	if gunshot_audio.playing:
		gunshot_audio.stop()
	
	# Play the gunshot sound
	gunshot_audio.play()
