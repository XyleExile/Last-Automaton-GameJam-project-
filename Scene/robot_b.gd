extends CharacterBody2D

@onready var animations = $AnimationPlayer

const SPEED = 60

var bullet = preload("res://Scene/Bullet.tscn")

var direction = "Right"

func handle_inputs():
	var move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = move_direction * SPEED
	
func update_animation():
	if velocity.length() == 0:
		animations.stop()
	else:
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
		elif velocity.y > 0: direction = "Down"
		
		animations.play("Walk_with_Gun" + direction)
	
func shooting():
	if Input.is_action_just_pressed("Shoot"):
		var bullet_instance = bullet.instantiate()
		bullet_instance.position = $Marker2D.global_position
		if direction == "Right": bullet_instance.rotation = 0
		elif direction == "Down": bullet_instance.rotation = PI/2
		elif direction == "Left": bullet_instance.rotation = PI
		elif direction == "Up": bullet_instance.rotation = 3*PI/2
		get_parent().add_child(bullet_instance)

func _physics_process(delta: float) -> void:
	handle_inputs()
	update_animation()
	shooting()
	move_and_slide()
