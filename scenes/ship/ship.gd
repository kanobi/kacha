extends CharacterBody2D

@export var speed = 200
@export var accel = 75
@export var rotation_speed = 5

var screen_size
var previous_position
var trail_line
var player_trail
var is_alive

signal death


func spawn():
	print("Spawned!")
	is_alive = true
	position = Vector2(828, 754)
	show()

func handle_death():
	print("Got hit!")
	death.emit()
	is_alive = false
	velocity = Vector2(0, 0)
	
	for i in range(1, player_trail.get_child_count()):
		player_trail.get_child(i).queue_free()
		trail_line.clear_points()

	hide()

func _ready():
	hide()
	is_alive = false
	velocity = Vector2(0, 0)
	screen_size = get_viewport_rect().size
	trail_line = get_tree().get_first_node_in_group("trail_line_grp")
	player_trail = get_tree().get_first_node_in_group("player_trail_grp")

func _process(delta):
	if not is_alive:
		return

	var rotation_direction = Input.get_axis("left", "right")
	var speed_input = Input.get_axis("down", "up")
	
	speed += speed_input * delta * accel
	speed = clampf(speed, 200, 400)
	
	var rot_diff = rotation_direction * rotation_speed * delta
	rotation += rot_diff
	
	velocity = Vector2(1, 0).rotated(rotation) * speed * delta
	
	var collision = move_and_collide(velocity)
	position = position.clamp(Vector2.ZERO, screen_size)
	if collision:
		handle_death()
		return
	
	var spawner_position = $TrailSpawner.global_position
	var new_collision_segment = StaticBody2D.new()
	var new_collision_shape = CollisionShape2D.new()
	var new_segment = SegmentShape2D.new()
	
	trail_line.add_point(spawner_position)
	
	# To prevent small un-marked collision line at the start
	if previous_position:
		new_segment.a = previous_position
		new_segment.b = spawner_position
	new_collision_shape.shape = new_segment
	new_collision_segment.add_child(new_collision_shape)
	player_trail.add_child(new_collision_segment)
	previous_position = spawner_position
