extends Node2D

enum GameState {
	MENU_MAIN,
	MENU_SETTINGS,
	MENU_LOCAL,
	MENU_MULTI,
	PLAYING_LOCAL,
	PLAYING_MULTI,
	GAME_OVER,
}

@onready var main_menu = $MainMenu

@export var music_on = false
@export var explosion_radius = 100
@export var trail_scene: PackedScene

var current_game_state: GameState
var amount_of_players: int
var current_player_count: int
var ship_scene = preload("res://scenes/ship/ship.tscn")

var showing_menu: bool

signal toggle_menu(show_menu: bool)
signal game_over()

# debug hud information
func process_hud():
	var text_1 = 0
	var text_2 = 0
	if get_node_or_null("Ship"):
		text_1 = $Ship.rotation
		text_2 = $Ship.speed

	$HUD.set_text_11(text_1)
	$HUD.set_text_21(text_2)

func spawn_player(spawn_points, idx):
	var spawn_position = spawn_points[idx]
	var player_ship = ship_scene.instantiate()
	add_child(player_ship)
	player_ship.player_id = idx
	player_ship.position = spawn_position.position
	player_ship.rotation = spawn_position.rotation
	player_ship.death.connect(_on_ship_death)
	player_ship.update_ship_trail.connect(_on_ship_update_trail)
	player_ship.spawn()

func spawn_players(amount):
	print("Spawning ", amount, " players")
	var spawn_points = $SpawnPositions.get_children()
	spawn_points.shuffle()
	var spawn_count = len(spawn_points)
	if amount > spawn_count:
		print(
			"ERROR: too many players to spawn. ",
			"Players: ", amount,
			"Spawnpoints: ", spawn_count
		)
		return
	for i in range(amount):
		spawn_player(spawn_points, i)

func clear_game():
	var trails = get_tree().get_nodes_in_group("trails")
	var ships = get_tree().get_nodes_in_group("ships")
	
	for trail in trails:
		trail.queue_free()
	
	for ship in ships:
		ship.queue_free()
	

func new_game(num_players):
	print("new game with num_players=", num_players)
	if music_on == true:
		$Music/MenuMusic.stop()
		$Music/GameMusic.play()
	amount_of_players = num_players
	current_player_count = num_players
	spawn_players(amount_of_players)

func handle_trails_damaged_by_explosion(trails, explosion_position):
	for trail in trails:
		var new_cuts = get_cuts_from_trail(trail, explosion_position)
		if new_cuts:
			var trail_ship = trail.trail_generator
			trail.queue_free()
			for new_trail_points in new_cuts.values():
				if len(new_trail_points) > 1:
					var new_trail_node = add_trail_node(new_trail_points)
					trail_ship.trail_node = new_trail_node

func get_cuts_from_trail(trail, explosion_position):
	var trail_line: Line2D = trail.get_node("TrailLine")
	var new_cuts = {}
	var cuts = 0
	var new_points = []
	var previous_skip = false
	for point in trail_line.points:
		if point.distance_to(explosion_position) < explosion_radius:
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
	return new_cuts

func update_trail_line(trail_node, trail_line, new_point, prev_point):
	# Add collision
	var new_segment = SegmentShape2D.new()
	var new_collision_shape = CollisionShape2D.new()
	var new_collision_segment = StaticBody2D.new()
	# To prevent small un-marked collision line at the start
	if prev_point:
		new_segment.a = prev_point
		new_segment.b = new_point
	new_collision_shape.shape = new_segment
	new_collision_segment.add_child(new_collision_shape)
	trail_node.add_child(new_collision_segment)
	# Draw line
	trail_line.add_point(new_point)

func add_trail_node(points):
	if current_game_state not in [
		GameState.PLAYING_LOCAL,
		GameState.PLAYING_MULTI
	]:
		return
	var new_trail_node = trail_scene.instantiate()
	var new_trail_line = new_trail_node.get_node("TrailLine")
	var previous_point
	for point in points:
		update_trail_line(
			new_trail_node, 
			new_trail_line,
			point,
			previous_point
		)
		previous_point = point
	get_tree().get_root().add_child(new_trail_node)
	return new_trail_node

func _on_ship_update_trail(ship_trail_node, new_point, previous_point):
	if current_game_state not in [
		GameState.PLAYING_LOCAL,
		GameState.PLAYING_MULTI
	]:
		return

	update_trail_line(
		ship_trail_node,
		ship_trail_node.get_node("TrailLine"),
		new_point,
		previous_point
	)

func _on_ship_death(ship):
	print("main_on_ship_death.")
	current_player_count -= 1
	if current_player_count < 2:
		_on_game_over()
		return
	
	# check if trails got damaged by ship's explosion
	var trails = get_tree().get_nodes_in_group("trails")
	var ship_position = ship.position
	for trail in trails:
		var new_cuts = get_cuts_from_trail(trail, ship_position)
		if new_cuts:
			var trail_ship = trail.trail_generator
			trail.queue_free()
			for new_trail_points in new_cuts.values():
				if len(new_trail_points) > 1:
					var new_trail_node = add_trail_node(new_trail_points)
					trail_ship.trail_node = new_trail_node

func _on_start_local_game(num_players: int):
	print("_on_start_local_game: ", str(num_players))
	current_game_state = GameState.PLAYING_LOCAL
	new_game(num_players)
	
func _on_restart_local_game():
	print("_on_restart_local_game: ", str(amount_of_players))
	current_game_state = GameState.PLAYING_LOCAL
	clear_game()
	new_game(amount_of_players)

func _on_game_over():
	print("_on_game_over")
	set_process(false)
	current_game_state = GameState.GAME_OVER
	
	# freeze remaining ships
	var ships = get_tree().get_nodes_in_group("ships")
	for ship in ships:
		ship.set_process(false)
	
	game_over.emit()

func _on_end_game():
	print("_on_end_game")
	set_process(false)
	current_game_state = GameState.MENU_MAIN
	clear_game()

func _on_hide_menu():
	showing_menu = false

func _ready():
	current_game_state = GameState.MENU_MAIN
	
	var menu_canvas = main_menu.get_node("CanvasLayer")
	menu_canvas.start_local_game.connect(_on_start_local_game)
	menu_canvas.restart_game.connect(_on_restart_local_game)
	menu_canvas.end_game.connect(_on_end_game)
	menu_canvas.hide_menu.connect(_on_hide_menu)
	
	toggle_menu.connect(menu_canvas._on_toggle_main_menu)
	game_over.connect(menu_canvas._on_show_game_over)
	
	if music_on == true:
		$Music/MenuMusic.play()
	set_process(false)

func _process(_delta):
	process_hud()

func _input(event):
	if event.is_action_pressed("exit"):
		if current_game_state in [
			GameState.PLAYING_LOCAL,
			GameState.PLAYING_MULTI
		]:
			showing_menu = !showing_menu
			print(showing_menu)
			toggle_menu.emit(showing_menu)
