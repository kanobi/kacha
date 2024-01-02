extends Node2D

@export var amount_of_players = 2
var current_player_count: int
var ship_scene = preload("res://scenes/ship/ship.tscn")

func process_hud():
	var text_1 = 0
	var text_2 = 0
	if get_node_or_null("Ship"):
		text_1 = $Ship.rotation
		text_2 = $Ship.speed

	$Hud.set_text_11(text_1)
	$Hud.set_text_21(text_2)

func spawn_players(amount):
	if amount > $SpawnPositions.get_child_count():
		print("no")
		return
	for i in range(amount):
		var spawn_position = $SpawnPositions.get_child(i)
		var player_ship = ship_scene.instantiate()
		add_child(player_ship)
		player_ship.player_id = i
		player_ship.position = spawn_position.position
		player_ship.rotation = spawn_position.rotation
		player_ship.spawn()
		player_ship.death.connect(_on_ship_death)

func new_game():
	print("new game")
	$Music/MenuMusic.stop()
	#$Music/GameMusic.play()
	$StartTimer.start()
	current_player_count = amount_of_players
	
func restart_game():
	print("restart")
	set_process(false)
	$Music/GameMusic.stop()
	#$Music/MenuMusic.play()
	$Hud.show_game_over()

func _ready():
	set_process(false)

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _process(delta):
	process_hud()

func _on_hud_start_game():
	new_game()

func _on_ship_death():
	current_player_count -= 1
	if current_player_count == 0:
		restart_game()

func _on_start_timer_timeout():
	print("playing")
	set_process(true)
	spawn_players(amount_of_players)
