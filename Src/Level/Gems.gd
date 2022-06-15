extends CanvasLayer

onready var level = get_parent()
onready var player = get_parent().get_node("Mage")
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
onready var slot1: TextureRect = get_node("Slots/Slot1/Gem")
onready var slot2: TextureRect = get_node("Slots/Slot2/Gem")
onready var slot3: TextureRect = get_node("Slots/Slot3/Gem")
var gem_id
var slot1Gem_id
var slot2Gem_id
var slot3Gem_id

enum types {Fire, Water, Earth, Air}
var orbs_collected = []
var diff_types = 4
var diff_sizes = 4
var mouse_over = false

func _ready():
	for x in diff_types:
		orbs_collected.append([])
		for y in range(diff_sizes):
			orbs_collected[x].append(0)
			gems.add_item(str(orbs_collected[x][y]), gems_paths[x * diff_sizes + y])

func _physics_process(_delta: float) -> void:
	var val = slot1.get_node("Bar").value
	if val > 0:
		slot1.get_node("Bar").set_value(val - 0.1)
	else:
		if slot1.texture != null:
			slot1.texture = null
			slot1.get_node("Bar").set_value(0)
			player.update_staff(-1)
	val = slot2.get_node("Bar").value
	if val > 0:
		slot2.get_node("Bar").set_value(val - 1)
	else:
		if slot2.texture != null:
			slot2.texture = null
			slot2.get_node("Bar").set_value(0)
			player.update_tower(-1)

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

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var mouse_position = get_viewport().get_mouse_position()
			var slot = slot_clicked(mouse_position)
			if slot == 0:
				choosedGem.texture = null
			else:
				if choosedGem.texture != null:
					if slot == 1:
						slot1.texture = gems_paths[gem_id]
						slot1Gem_id = gem_id
						slot1.get_node("Bar").set_value(100)
						player.update_staff(gem_id)
					elif slot == 2:
						slot2.texture = gems_paths[gem_id]
						slot2Gem_id = gem_id
						slot2.get_node("Bar").set_value(100)
						player.update_tower(gem_id)
					elif slot == 3:
						slot3.texture = gems_paths[gem_id]
						slot3Gem_id = gem_id
						slot3.get_node("Bar").set_value(100)
						level.update_strength(gem_id)
					orbs_collected[int(gem_id / diff_sizes)][(gem_id % diff_sizes)] -= 1
					gems.set_item_text(gem_id, str(orbs_collected[int(gem_id / diff_sizes)][(gem_id % diff_sizes)]))
					choosedGem.texture = null
	choosedGem.set_position(get_viewport().get_mouse_position())

func slot_clicked(pos: Vector2) -> int:
	var x_area = Vector2(1830, 1880)
	var y_area1 = Vector2(40, 90)
	var y_area2 = Vector2(100, 150)
	var y_area3 = Vector2(160, 210)
	if x_area.x <= pos.x and pos.x <= x_area.y:
		if y_area1.x <= pos.y and pos.y <= y_area1.y:
			return 1
		elif y_area2.x <= pos.y and pos.y <= y_area2.y:
			return 2
		if y_area3.x <= pos.y and pos.y <= y_area3.y:
			return 3
	return 0

func _on_Gems_selected(index):
	if orbs_collected[int(index / diff_sizes)][(index % diff_sizes)] != 0:
		choosedGem.texture = gems_paths[index]
		gem_id = index
