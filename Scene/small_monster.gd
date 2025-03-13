extends CharacterBody2D

@export var speed: float = 100
@export var damage_cooldown: float = 1.0  # Cooldown between damage instances
@export var knockback_force: float = 200  # Increased knockback force
@export var detection_range: float = 450  # How far the monster can detect the player
@export var idle_movement_speed: float = 30.0  # Slower speed when not chasing
@export var attack_animation_duration: float = 0.5  # Duration of attack animation
@export var max_health: int = 100  # Maximum health for the small monster
@export var bullet_knockback_force: float = 200.0  # Knockback force when hit by bullets (higher than big monster)

@onready var player = $"../Player"
@onready var area_2d = $Area2D
@onready var animated_sprite = $AnimatedSprite2D  # Reference to the AnimatedSprite2D
@export var room_controller: Node2D  # Manually assign this in the Inspector


var can_damage: bool = true
var damage_timer: float = 0.0
var last_direction: Vector2 = Vector2.DOWN  # Store last direction for animation
var bodies_in_area = []
var player_detected: bool = false
var idle_direction: Vector2 = Vector2.ZERO
var idle_direction_timer: float = 0.0
var idle_direction_change_time: float = 3.0  # Change direction every 3 seconds when idle
var path_finding_cooldown: float = 0.0
var path_finding_interval: float = 0.5  # How often to recalculate path
var is_attacking: bool = false
var attack_timer: float = 0.0
var current_health: int = 100  # Current health, initialized to max_health
var is_alive: bool = true  # Track if the monster is alive

func _ready():
	# Add to monsters group
	add_to_group("monsters")
	
	# Connect the area signals
	area_2d.connect("body_entered", _on_area_2d_body_entered)
	area_2d.connect("body_exited", _on_area_2d_body_exited)
	# Initialize random idle direction
	randomize()
	change_idle_direction()
	
	# Connect animation finished signal if it exists
	if animated_sprite.has_signal("animation_finished"):
		animated_sprite.connect("animation_finished", _on_animation_finished)
	
	# Initialize health
	current_health = max_health

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
		
	if not player.alive:
		velocity = Vector2.ZERO  # Stop chasing if player is dead
		animated_sprite.play("idle")
		return
	
	# Handle attack animation timer
	if is_attacking:
		attack_timer += delta
		if attack_timer >= attack_animation_duration:
			is_attacking = false
			attack_timer = 0.0
	
	# Handle damage cooldown
	if not can_damage:
		damage_timer += delta
		if damage_timer >= damage_cooldown:
			can_damage = true
			damage_timer = 0.0
	
	# Check for continuous damage to player
	if can_damage and player in bodies_in_area:
		damage_player()
	
	# Don't move while attacking
	if is_attacking:
		velocity = Vector2.ZERO
		update_animation()
		return
	
	# Check if player is within detection range
	var distance_to_player = global_position.distance_to(player.global_position)
	player_detected = distance_to_player <= detection_range
	
	var direction: Vector2
	
	if player_detected:
		# Chase the player
		direction = (player.global_position - global_position).normalized()
		
		# Test if moving directly toward the player would hit a wall
		var test_velocity = direction * speed
		var test_collision = move_and_collide(test_velocity * delta, true)
		
		if test_collision:
			var collider = test_collision.get_collider()
			# If we would hit a wall (not the player), try to find a way around
			if collider != player:
				# Try to slide along the wall
				test_velocity = test_velocity.slide(test_collision.get_normal())
				
				# If the slide direction is too different from our original direction,
				# try a different approach to avoid getting stuck
				if test_velocity.normalized().dot(direction) < 0.5:
					# Try moving more to the left or right of the obstacle
					var perpendicular = Vector2(-direction.y, direction.x)
					if randf() > 0.5:
						perpendicular = -perpendicular
					
					test_velocity = (direction + perpendicular).normalized() * speed
					
					# Test this new direction
					test_collision = move_and_collide(test_velocity * delta, true)
					if test_collision and collider != player:
						# If still hitting a wall, try the other side
						test_velocity = (direction - perpendicular).normalized() * speed
				
				velocity = test_velocity
			else:
				velocity = direction * speed
		else:
			velocity = direction * speed
	else:
		# Idle movement when player not detected
		idle_direction_timer += delta
		if idle_direction_timer >= idle_direction_change_time:
			change_idle_direction()
			idle_direction_timer = 0.0
		
		direction = idle_direction
		
		# Test if idle movement would hit a wall
		var test_velocity = direction * idle_movement_speed
		var test_collision = move_and_collide(test_velocity * delta, true)
		
		if test_collision:
			# If we would hit a wall, change direction
			change_idle_direction()
			velocity = idle_direction * idle_movement_speed
		else:
			velocity = direction * idle_movement_speed
	
	# Store last significant direction for animation
	if direction.length() > 0.1:  # Only update if we have a significant direction
		last_direction = direction
	
	# Apply movement with proper collision handling
	var collision = move_and_slide()
	
	update_animation()

func change_idle_direction():
	# Generate a random direction for idle movement
	var angle = randf_range(0, 2 * PI)
	idle_direction = Vector2(cos(angle), sin(angle)).normalized()

func update_animation():
	# If attacking, play attack animation based on direction
	if is_attacking:
		play_attack_animation()
		return
		
	# Use the last significant direction for more stable animations
	if velocity.length() < 10:  # Almost stationary
		animated_sprite.play("idle")
		return
		
	if abs(last_direction.x) > abs(last_direction.y):
		# Horizontal movement is dominant
		if last_direction.x < 0:
			animated_sprite.play("left")
			animated_sprite.flip_h = false
		else:
			animated_sprite.play("right")
			animated_sprite.flip_h = false
	else:
		# Vertical movement is dominant
		if last_direction.y < 0:
			animated_sprite.play("up")
		else:
			animated_sprite.play("down")

func play_attack_animation():
	# Play attack animation based on the last direction
	if abs(last_direction.x) > abs(last_direction.y):
		# Horizontal attack
		if last_direction.x < 0:
			animated_sprite.play("attack_left")
			animated_sprite.flip_h = false
		else:
			animated_sprite.play("attack_right")
			animated_sprite.flip_h = false
	else:
		# Vertical attack
		if last_direction.y < 0:
			# Use attack_left for upward attack
			animated_sprite.play("attack_left")
		else:
			# Use attack_right for downward attack
			animated_sprite.play("attack_right")

func _on_animation_finished():
	# This will be called when an animation finishes playing
	if is_attacking:
		is_attacking = false
		attack_timer = 0.0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		bodies_in_area.append(body)
		if can_damage:
			damage_player()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body in bodies_in_area:
		bodies_in_area.erase(body)

func damage_player():
	if not is_alive:
		return
		
	print("player damaged by small monster")
	player.take_damage()  # Deal 1 damage
	can_damage = false
	damage_timer = 0.0
	
	# Start attack animation
	is_attacking = true
	attack_timer = 0.0
	
	# Calculate knockback direction
	var knockback_direction = (player.global_position - global_position).normalized()
	
	# Instead of directly setting velocity, we'll set a knockback flag and let the player handle it
	player.knockback_active = true
	player.knockback_timer = 0.0
	
	# Set player velocity for knockback, but with a safety check
	var knockback_velocity = knockback_direction * knockback_force
	
	# Test if the knockback would cause a collision with a wall
	var test_collision = player.move_and_collide(knockback_velocity * 0.016, true)  # Test with one frame's worth of movement
	if test_collision:
		var collider = test_collision.get_collider()
		# If we would hit a wall (not a monster), adjust the knockback to slide along the wall
		if not (collider.name.begins_with("big_monster") or collider.name.begins_with("small_monster")):
			# Slide along the wall
			knockback_velocity = knockback_velocity.slide(test_collision.get_normal())
			
			# Significantly reduce the force when hitting a wall to prevent pushing through
			knockback_velocity *= 0.3
			
			# Do a second test to make sure we're not still going to hit the wall
			var second_test = player.move_and_collide(knockback_velocity * 0.016, true)
			if second_test:
				# If we're still going to hit something, reduce force even more or stop completely
				knockback_velocity *= 0.1
				
				# Third test - if still hitting, just stop the knockback
				var third_test = player.move_and_collide(knockback_velocity * 0.016, true)
				if third_test:
					knockback_velocity = Vector2.ZERO
	
	# Apply the (potentially adjusted) knockback
	player.velocity = knockback_velocity
	
	# Move the monster slightly away from the player to prevent pushing
	velocity = -knockback_direction * (speed * 0.5)
	move_and_slide()

# Function to handle taking damage from bullets
func take_damage(damage_amount: int, bullet_position: Vector2) -> void:
	if not is_alive:
		return
		
	current_health -= damage_amount
	print("Small monster took damage! Current health: ", current_health)
	
	# Apply knockback from bullet
	var knockback_direction = (global_position - bullet_position).normalized()
	velocity = knockback_direction * bullet_knockback_force
	
	# Apply the knockback movement
	move_and_slide()
	
	# Visual feedback - flash the sprite
	if animated_sprite:
		animated_sprite.modulate = Color(1, 0.3, 0.3)  # Red tint
		await get_tree().create_timer(0.1).timeout
		animated_sprite.modulate = Color(1, 1, 1)  # Back to normal
	
	# Check if monster is dead
	if current_health <= 0:
		die()

# Function to handle monster death
func die() -> void:
	print("Small monster died!")
	is_alive = false
	
	# Set health to 0
	current_health = 0
	
	# Play the dead animation - we know it exists
	animated_sprite.play("dead")

	# Disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	area_2d.set_deferred("monitoring", false)
	area_2d.set_deferred("monitorable", false)
	
	# Notify the room controller
	if room_controller:
		room_controller.monster_died(self)
	
	# Queue free after a delay to allow death animation to play
	await get_tree().create_timer(1.0).timeout
	queue_free()
