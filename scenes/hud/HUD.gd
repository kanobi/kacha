extends Control

func set_text_11(label_text):
	$TextRows/Row1/Text11.text = str(label_text)

func set_text_21(label_text):
	$TextRows/Row2/Text21.text = str(label_text)

func _ready():
	$TextRows/Row1/Label11.text = "Rotation: "
	$TextRows/Row2/Label21.text = "Velocity: "

func _process(delta):
	pass
