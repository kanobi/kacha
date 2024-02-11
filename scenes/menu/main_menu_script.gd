extends CanvasLayer

@onready var main_control: Control = $Main
@onready var local_game_control: Control = $PlayLocal
@onready var settings_control: Control = $Settings
@onready var end_game_control: Control = $ShowEndGame
@onready var game_over_control: Control = $ShowGameOver

@onready var num_players_control: Range = $PlayLocal/CenterContainer/PanelContainer/MarginContainer/VBoxContainer1/VBoxContainer2/HSplitContainer/NumPlayers

signal start_local_game(num_players: int)
signal restart_game()
signal end_game()
signal hide_menu()


# Main menu

func _on_toggle_main_menu(show_menu: bool):
	if show_menu:
		end_game_control.show()
	else:
		end_game_control.hide()

func _on_button_play_local_pressed():
	main_control.hide()
	local_game_control.show()

func _on_button_multiplayer_pressed():
	pass

func _on_button_settings_pressed():
	main_control.hide()
	settings_control.show()

func _on_button_quit_pressed():
	get_tree().quit()


# Settings menu

func _on_button_back_pressed():
	main_control.show()
	settings_control.hide()


# Local Game menu

func _on_button_local_back_pressed():
	main_control.show()
	local_game_control.hide()

func _on_button_local_play_pressed():
	local_game_control.hide()
	var num_players = int(num_players_control.value)
	start_local_game.emit(num_players)


# End Game menu

func _on_button_resume_pressed():
	end_game_control.hide()
	hide_menu.emit()

func _on_button_main_menu_pressed():
	end_game_control.hide()
	main_control.show()
	end_game.emit()


# Game Over menu

func _on_show_game_over():
	game_over_control.show()

func _on_button_game_over_menu_pressed():
	game_over_control.hide()
	main_control.show()
	end_game.emit()

func _on_button_restart_pressed():
	game_over_control.hide()
	restart_game.emit()
