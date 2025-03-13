extends CharacterBody2D

@onready var animations = $AnimationPlayer

const SPEED = 60
var health = 100

func handle_inputs():
	var move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = move_direction * SPEED
	
func update_animation():
	if velocity.length() == 0:
		animations.stop()
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
		
		animations.play("Walk" + direction)
	
func _physics_process(delta: float) -> void:
	handle_inputs()
	update_animation() 
	move_and_slide()
	
func take_damage(damage: int):
	health -= damage
	print("Player health: " + str(health))
	if health <= 0:
		die()
		
func die():
	print("Player has died!")
	# Handle player death (e.g., restart level, show game over screen)
