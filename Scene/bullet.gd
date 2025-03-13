extends Area2D

@onready var animations = $AnimationPlayer

var SPEED = 800
var damage = 5  # Damage amount for big monster

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true)
	# Connect the area entered signal
	connect("body_entered", _on_body_entered)
	connect("area_entered", _on_area_entered)


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.frame = 0
	set_physics_process(false)

func _process(delta: float) -> void:
	position += (Vector2.RIGHT * SPEED).rotated(rotation) * delta
	
# Handle collision with bodies (like big_monster)
func _on_body_entered(body: Node2D) -> void:
	# Check if the body is a big monster
	if body.is_in_group("monsters") or body.name.begins_with("big_monster"):
		# Check if the monster has the take_damage method
		if body.has_method("take_damage"):
			body.take_damage(damage, global_position)
		queue_free()
	elif not body.name.begins_with("Player"):
		# If hit something other than player or monster, just destroy the bullet
		queue_free()

# Handle collision with areas
func _on_area_entered(area: Area2D) -> void:
	# If the area is part of a monster, try to get the parent
	var parent = area.get_parent()
	if parent and (parent.is_in_group("monsters") or parent.name.begins_with("big_monster")):
		if parent.has_method("take_damage"):
			parent.take_damage(damage, global_position)
		queue_free()
	elif not area.name.begins_with("Player"):
		# If hit something other than player or monster, just destroy the bullet
		queue_free()
	
