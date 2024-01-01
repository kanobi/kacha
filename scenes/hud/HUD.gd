extends CanvasLayer

signal start_game

var end_msgs = [
	"You've bitten more than you could chew!",
	"You are no more.",
	"You are sleeping with the fishes.",
	"Wasted!",
	"You're dead as a parrot!",
	"You perished!",
	"You're stone dead!",
	"That's what I call a dead snake!",
	"You are deceased.",
	"You cease to exist.",
	"You have passed on.",
	"You have expired and gone to see your maker!",
	"You are bereft of life!",
]

func set_text_11(label_text):
	$DebugInfo/TextRows/Row1/Text11.text = str(label_text)

func set_text_21(label_text):
	$DebugInfo/TextRows/Row2/Text21.text = str(label_text)

func _ready():
	$DebugInfo/TextRows/Row1/Label11.text = "Rotation: "
	$DebugInfo/TextRows/Row2/Label21.text = "Velocity: "
	$CenterMessage.text = "Get ready!"

func show_game_over():
	$CenterMessage.text = end_msgs[randi_range(0, len(end_msgs) - 1)]
	$CenterMessage.show()
	$StartButton.show()

func _on_start_button_pressed():
	$StartButton.hide()
	$CenterMessage.hide()
	start_game.emit()
