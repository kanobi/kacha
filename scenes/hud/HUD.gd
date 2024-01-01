extends CanvasLayer

signal start_game

func set_text_11(label_text):
	$DebugInfo/TextRows/Row1/Text11.text = str(label_text)

func set_text_21(label_text):
	$DebugInfo/TextRows/Row2/Text21.text = str(label_text)

func _ready():
	$DebugInfo/TextRows/Row1/Label11.text = "Rotation: "
	$DebugInfo/TextRows/Row2/Label21.text = "Velocity: "

func show_game_over():
	$CenterMessage.text = "You've bitten more than you can chew!"
	$CenterMessage.show()
	$StartButton.show()

func _on_start_button_pressed():
	$StartButton.hide()
	$CenterMessage.hide()
	start_game.emit()
