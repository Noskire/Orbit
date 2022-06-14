extends CanvasLayer

# types {Fire, Water, Earth, Air}
# sizes {Small, Medium, Large}
onready var gems_paths = [
	preload("res://icon.png"), preload("res://icon.png"), preload("res://icon.png"), preload("res://icon.png"),
	preload("res://icon.png"), preload("res://icon.png"), preload("res://icon.png"), preload("res://icon.png"),
	preload("res://icon.png"), preload("res://icon.png"), preload("res://icon.png"), preload("res://icon.png"),
	preload("res://icon.png"), preload("res://icon.png"), preload("res://icon.png"), preload("res://icon.png")
	]
onready var gems: ItemList = get_node("Gems")
onready var choosedGem: TextureRect = get_node("ChoosedGem")

enum types {Fire, Water, Earth, Air}
var orbs_collected = []
var diff_types = 4
var diff_sizes = 4

func _ready():
	for x in diff_types:
		orbs_collected.append([])
		for y in range(diff_sizes):
			orbs_collected[x].append(0)
			gems.add_item(str(orbs_collected[x][y]), gems_paths[x * diff_sizes + y])

func get_orb(value, type) -> void:
	orbs_collected[type][0] += value
	gems.set_item_text((type * diff_sizes), str(orbs_collected[type][0]))
	if orbs_collected[type][0] >= 10:
		orbs_collected[type][0] -= 10
		orbs_collected[type][1] += 1
		gems.set_item_text((type * diff_sizes), str(orbs_collected[type][0]))
		gems.set_item_text((type * diff_sizes + 1), str(orbs_collected[type][1]))
		if orbs_collected[type][1] >= 10:
			orbs_collected[type][1] -= 10
			orbs_collected[type][2] += 1
			gems.set_item_text((type * diff_sizes + 1), str(orbs_collected[type][1]))
			gems.set_item_text((type * diff_sizes + 2), str(orbs_collected[type][2]))
			if orbs_collected[type][2] >= 10:
				orbs_collected[type][2] -= 10
				orbs_collected[type][3] += 1
				gems.set_item_text((type * diff_sizes + 2), str(orbs_collected[type][2]))
				gems.set_item_text((type * diff_sizes + 3), str(orbs_collected[type][3]))
	print(orbs_collected)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var mouse_position = get_viewport().get_mouse_position()
	choosedGem.set_position(get_viewport().get_mouse_position())

func _on_Gems_selected(index):
	choosedGem.texture = gems_paths[index]
