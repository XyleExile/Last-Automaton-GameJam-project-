extends CharacterBody2D

@onready var animations = $AnimationPlayer

const SPEED = 250
var alive : bool = true
var has_gun : bool = false  # Track if player has collected the gun

var heart_list : Array[TextureRect]
var health = 6
var knockback_active = false
var knockback_timer = 0.0
var knockback_duration = 0.3  # Slightly longer knockback duration
var invincibility_timer = 0.0
var invincibility_duration = 0.5  # Short invincibility after being hit
var death_animation_played = false  # Track if death animation has played

func _ready() -> void:
	# Add player to the "player" group for easy access
	add_to_group("player")
	
	var hearts_parent = $Heart_Bar/HBoxContainer
	for child in hearts_parent.get_children():
		heart_list.append(child)
	print(heart_list)
	
	# Connect to the area2D for continuous collision detection
	$Area2D.connect("body_entered", _on_area_2d_body_entered)
	
	# Hide the gun initially
	if has_node("Gun"):
		$Gun.visible = false
		has_gun = false

func take_damage(amount: int = 1):
	if health > 0 and invincibility_timer <= 0:
		health -= amount
		# can add damage animation if got $damage.play("damaged")
		update_heart_display()
		knockback_active = true
		knockback_timer = 0.0
		invincibility_timer = invincibility_duration  # Set invincibility after hit

func update_heart_display():
	for i in range(heart_list.size()):
		heart_list[i].visible = i < health
	
	# heart beat animation if 1 health
	if health == 1:
		heart_list[0].get_child(0).play("beating")
	elif health > 1:
		heart_list[0].get_child(0).play("idle")

	# player dead
	if health <= 0:
		alive = false
		# Play death animation if available
		if animations.has_animation("death"):
			animations.play("death")
		else:
			# If no death animation, just use idle
			animations.play("idle")
		
		# Handle player death with a delay to show animation
		handle_player_death()
		
		set_physics_process(false)  # Stop player movement

# Handle player death and transition to lose screen
func handle_player_death():
	if death_animation_played:
		return
		
	death_animation_played = true
	
	# Wait a moment before transitioning to the lose screen
	await get_tree().create_timer(1.5).timeout
	
	# Transition to lose screen using GameManager
	if get_node("/root/GameManager"):
		get_node("/root/GameManager").player_lose()

func handle_inputs():
	if not alive:
		return  # Prevent movement when dead
		
	if knockback_active:
		return  # Don't allow player control during knockback

	var move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_direction * SPEED

func update_animation():
	# Don't update animation if player is dead
	if not alive:
		return
		
	var direction = "idle"
	if velocity.length() == 0:
		direction = "idle"
	else:
		direction = "down"
		if velocity.x < 0: direction = "left"
		elif velocity.x > 0: direction = "right"
		elif velocity.y < 0: direction = "up"

	animations.play(direction)

func _physics_process(delta: float) -> void:
	# Handle invincibility timer
	if invincibility_timer > 0:
		invincibility_timer -= delta
	
	# Handle knockback timer
	if knockback_active:
		knockback_timer += delta
		if knockback_timer >= knockback_duration:
			knockback_active = false
			knockback_timer = 0.0
			velocity = Vector2.ZERO
		
		# During knockback, check for wall collisions to prevent being pushed through walls
		var test_collision = move_and_collide(velocity * delta, true)
		if test_collision:
			var collider = test_collision.get_collider()
			if not (collider.name.begins_with("big_monster") or collider.name.begins_with("small_monster")):
				# If we're about to hit a wall during knockback, slide along it and reduce velocity
				velocity = velocity.slide(test_collision.get_normal()) * 0.8
	
	handle_inputs()
	update_animation()
	
	# First test the movement with move_and_collide (without actually moving)
	var test_collision = move_and_collide(velocity * delta, true)
	if test_collision:
		var collider = test_collision.get_collider()
		if collider.name.begins_with("big_monster") or collider.name.begins_with("small_monster"):
			# If we're moving upward into an enemy (approaching from below)
			if velocity.y < 0 and test_collision.get_normal().y > 0:
				# Add a horizontal component to slide around
				velocity = velocity.rotated(0.3 * sign(randf() - 0.5))
				
			# Apply the movement with sliding
			velocity = velocity.slide(test_collision.get_normal())
			move_and_slide()
		else:
			# For other collisions, just use move_and_slide
			move_and_slide()
	else:
		# No collision detected, proceed normally
		move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name.begins_with("big_monster") or body.name.begins_with("small_monster"):
		print("player hit by enemy")
		# The enemy will handle the damage and knockback in its own script

# Function to collect the gun
func collect_gun():
	has_gun = true
	if has_node("Gun"):
		$Gun.visible = true
		print("Gun collected!")
