extends Control

export(String, FILE) var scenePath: = ""
var tuto = 1

func _input(event):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed) or Input.is_action_just_pressed("shoot"):
		if tuto == 1:
			$Tuto1.set_visible(false)
			$Tuto2.set_visible(true)
			tuto += 1
		else:
			var err = get_tree().change_scene(scenePath)
			if err != OK:
				print("Error Play Button")
			pass
