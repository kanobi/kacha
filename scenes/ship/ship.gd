extends CharacterBody2D

@export var speed = 200
@export var accel = 75
@export var rotation_speed = 5

var screen_size
var previous_position
var trail_line
var player_trail

func _ready():
	velocity = Vector2(1, 1)
	screen_size = get_viewport_rect().size
	trail_line = get_tree().get_first_node_in_group("trail_line_grp")
	player_trail = get_tree().get_first_node_in_group("player_trail_grp")
	previous_position = $TrailSpawner.global_position


func _process(delta):
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
		print("I collided with ", collision.get_collider().name)
		player_trail.queue_free()
		queue_free()
	
	var spawner_position = $TrailSpawner.global_position
	var new_collision_segment = StaticBody2D.new()
	var new_collision_shape = CollisionShape2D.new()
	var new_segment = SegmentShape2D.new()
	
	trail_line.add_point(spawner_position)
	
	new_segment.a = previous_position
	new_segment.b = spawner_position
	new_collision_shape.shape = new_segment
	new_collision_segment.add_child(new_collision_shape)
	player_trail.add_child(new_collision_segment)
	previous_position = spawner_position
