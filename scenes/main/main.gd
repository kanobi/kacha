extends Node2D

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

func _ready():
	pass

func _process(delta):
	process_keys()
	process_hud()
