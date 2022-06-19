extends Control

onready var sceneTree: = get_tree()
onready var lscore: Label = get_node("Score")
onready var enterBoard = get_node("EnterBoard")

export(String, FILE) var screen_path: = ""

func _ready():
	lscore.set_text(str(tr("SCORE"), GlobalSettings.score))

func _on_MainMenu_button_up():
	var err
	err = sceneTree.change_scene(screen_path)
	if err != OK:
		print("Error change_scene MenuButton")
