extends CanvasLayer

signal start_solo
signal start_duo

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

func show_game_over():
	$CenterMessage.text = end_msgs[randi_range(0, len(end_msgs) - 1)]
	show_menu()

func show_menu():
	$CenterMessage.show()
	$StartSolo.show()
	$StartDuo.show()

func hide_menu():
	$StartSolo.hide()
	$StartDuo.hide()
	$CenterMessage.hide()

func _ready():
	$DebugInfo/TextRows/Row1/Label11.text = "Rotation: "
	$DebugInfo/TextRows/Row2/Label21.text = "Velocity: "
	$CenterMessage.text = "Get ready!"

func _on_start_solo_pressed():
	hide_menu()
	start_solo.emit()

func _on_start_duo_pressed():
	hide_menu()
	start_duo.emit()
