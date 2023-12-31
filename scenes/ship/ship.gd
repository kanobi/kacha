extends CharacterBody2D

@export var speed = 200
@export var accel = 75
@export var rotation_speed = 5

@export var trail_scene: PackedScene

var player_id: int
var trail_line: Node
var trail_node: Node
var screen_size
var previous_position

signal death

func spawn():
	print("Spawned!")
	trail_node = trail_scene.instantiate()
	add_child(trail_node)
	trail_line = trail_node.get_node("TrailLine")
	set_process(true)

func handle_death():
	print("Got hit!")
	death.emit()
	set_process(false)
	velocity = Vector2(1, 0)
	trail_node.queue_free()
	queue_free()

func update_trail():
	var spawner_position = $TrailSpawner.global_position
	var new_collision_segment = StaticBody2D.new()
	var new_collision_shape = CollisionShape2D.new()
	
	# Draw line
	trail_line.add_point(spawner_position)
	
	# Add collision
	var new_segment = SegmentShape2D.new()

	# To prevent small un-marked collision line at the start
	if previous_position:
		new_segment.a = previous_position
		new_segment.b = spawner_position

	new_collision_shape.shape = new_segment
	new_collision_segment.add_child(new_collision_shape)
	trail_node.add_child(new_collision_segment)
	previous_position = spawner_position

func _ready():
	velocity = Vector2(0, 0)
	screen_size = get_viewport_rect().size

func _process(delta):
	# TODO: find better way of handling input
	var rotation_direction
	match player_id:
		0: 
			rotation_direction = Input.get_axis("left", "right")
		1:
			rotation_direction = Input.get_axis("left1", "right1")
		_:
			rotation_direction = Vector2(1,1)
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

	update_trail()
