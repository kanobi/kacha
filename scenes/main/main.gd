extends Node2D

@export var music_on = false
@export var explosion_radius = 100
@export var trail_scene: PackedScene

var amount_of_players: int
var current_player_count: int
var ship_scene = preload("res://scenes/ship/ship.tscn")


# debug hud information
func process_hud():
	var text_1 = 0
	var text_2 = 0
	if get_node_or_null("Ship"):
		text_1 = $Ship.rotation
		text_2 = $Ship.speed

	$Hud.set_text_11(text_1)
	$Hud.set_text_21(text_2)

func spawn_players(amount):
	var spawn_points = $SpawnPositions.get_children()
	var spawn_count = len(spawn_points)
	if amount > spawn_count:
		print(
			"ERROR: too many players to spawn. ",
			"Players: ", amount,
			"Spawnpoints: ", spawn_count
		)
		return

	spawn_points.shuffle()
	for i in range(amount):
		var spawn_position = spawn_points[i]
		var player_ship = ship_scene.instantiate()
		player_ship.player_id = i
		player_ship.position = spawn_position.position
		player_ship.rotation = spawn_position.rotation
		player_ship.spawn()
		player_ship.death.connect(_on_ship_death)
		add_child(player_ship)

func new_game(num_players):
	print("new game with num_players=", num_players)
	if music_on == true:
		$Music/MenuMusic.stop()
		$Music/GameMusic.play()
	amount_of_players = num_players
	current_player_count = num_players
	$StartTimer.start()
	
func restart_game():
	print("restart")
	set_process(false)
	if music_on == true:
		$Music/GameMusic.stop()
		$Music/MenuMusic.play()
	$Hud.show_game_over()

func _ready():
	if music_on == true:
		$Music/MenuMusic.play()
	set_process(false)

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _process(delta):
	process_hud()

func _on_ship_death(ship):
	print("main_on_ship_death.")
	current_player_count -= 1
	var trails = get_tree().get_nodes_in_group("trails")
	
	if current_player_count == 0:
		# clear all trails	
		for trail in trails:
			trail.queue_free()
		restart_game()
		return
	
	# check if trails got damaged by ship's explosion
	var ship_position = ship.position
	for trail in trails:
		var trail_line: Line2D = trail.get_node("TrailLine")
		var new_cuts = {}
		var cuts = 0
		var new_points = []
		var previous_skip = false
		for i in trail_line.points.size():
			var point = trail_line.points[i]
			if point.distance_to(ship_position) < explosion_radius:
				if not previous_skip:
					if len(new_points) > 1:
						new_cuts[cuts] = new_points.duplicate(true)
						cuts += 1
					new_points = []
				previous_skip = true
			else:
				new_points.append(point)
				previous_skip = false
		if len(new_points) > 1:
			new_cuts[cuts] = new_points.duplicate(true)
			cuts += 1
			new_points = []
		
		if new_cuts:
			var trail_ship = trail.trail_generator
			trail.queue_free()
			for new_trail_points in new_cuts.values():
				if len(new_trail_points) > 1:
					var new_trail_node = trail_scene.instantiate()
					var new_trail_line = new_trail_node.get_node("TrailLine")
					for point in new_trail_points:
						# Draw line
						new_trail_line.add_point(point)
						# Add collision
						var new_collision_segment = StaticBody2D.new()
						var new_collision_shape = CollisionShape2D.new()
						new_collision_shape.shape = SegmentShape2D.new()
						new_collision_shape.global_position = point
						new_collision_segment.add_child(new_collision_shape)
						new_trail_node.add_child(new_collision_segment)
					get_tree().get_root().add_child(new_trail_node)
					trail_ship.trail_node = new_trail_node

func _on_start_timer_timeout():
	print("playing a game with player count: ", amount_of_players)
	set_process(true)
	spawn_players(amount_of_players)

func _on_hud_start_solo():
	new_game(1)

func _on_hud_start_duo():
	new_game(2)
