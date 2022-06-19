extends Control

onready var playButton = $Margin/VBox/Menu/Play
onready var settingsMenu = $SettingsMenu
export(String, FILE) var scenePath: = ""

func _ready():
	playButton.grab_focus()

func _on_Play_button_up():
	var err = get_tree().change_scene(scenePath)
	if err != OK:
		print("Error Play Button")
	pass

func _on_Settings_button_up():
	settingsMenu.popup()

func _on_Quit_button_up():
	get_tree().quit()

func _on_Link_pressed():
	var err = OS.shell_open("https://noskire.itch.io/")
	if err != OK:
		print("Error Play Button")
	pass
