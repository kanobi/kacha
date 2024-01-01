extends Node2D

var is_playing

func process_hud():
	var text_1 = 0
	var text_2 = 0
	if get_node_or_null("Ship"):
		text_1 = $Ship.rotation
		text_2 = $Ship.speed

	$Hud.set_text_11(text_1)
	$Hud.set_text_21(text_2)

func process_keys():
	if Input.is_action_pressed("exit"):
		get_tree().quit()

func new_game():
	print("new game")
	$Music/MenuMusic.stop()
	$Music/GameMusic.play()
	$StartTimer.start()
	
func restart_game():
	print("restart")
	is_playing = false
	$Music/GameMusic.stop()
	$Music/MenuMusic.play()
	$Hud.show_game_over()

func _ready():
	is_playing = false

func _process(delta):
	if not is_playing:
		return
	process_keys()
	process_hud()

func _on_hud_start_game():
	new_game()

func _on_ship_death():
	restart_game()

func _on_start_timer_timeout():
	print("playing")
	is_playing = true
	$Ship.spawn()
