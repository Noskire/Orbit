extends Control

onready var sceneTree: = get_tree()
onready var pauseOverlay: ColorRect = get_node("PauseOverlay")
onready var settingsMenu = get_node("SettingsMenu")

export(String, FILE) var mainenu_scene_path: = ""
export(String, FILE) var scenePath: = ""

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible: # Paused
			sceneTree.paused = false
			visible = false
		else:
			sceneTree.paused = true
			visible = true
			$PauseOverlay/VBox/Resume.grab_focus()
		sceneTree.set_input_as_handled()

func game_over():
	sceneTree.paused = false
	var err = get_tree().change_scene(scenePath)
	if err != OK:
		print("Error Level to End Screen")

func _on_Resume_button_up():
	sceneTree.paused = false
	visible = false

func _on_Restart_button_up():
	sceneTree.paused = false
	var err
	err = sceneTree.reload_current_scene()
	if err != OK:
		print("Error reload scene RestartButton")

func _on_Settings_button_up():
	settingsMenu.popup_centered()

func _on_MainMenu_button_up():
	sceneTree.paused = false
	var err
	err = sceneTree.change_scene(mainenu_scene_path)
	if err != OK:
		print("Error change_scene MenuButton")
