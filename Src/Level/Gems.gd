extends CanvasLayer

onready var level = get_parent()
onready var player = get_parent().get_node("Mage")
# types {Fire, Water, Earth, Air}
# sizes {Small, Medium, Large}
onready var gems_paths = [
	preload("res://Assets/HUD/gem1.png"), preload("res://Assets/HUD/gem2.png"),
	preload("res://Assets/HUD/gem3.png"), preload("res://Assets/HUD/gem4.png")
	]
onready var gems: ItemList = get_node("Gems")
onready var choosedGem: TextureRect = get_node("ChoosedGem")
onready var slot1: TextureRect = get_node("Slots/Slot1/Gem")
onready var slot2: TextureRect = get_node("Slots/Slot2/Gem")
onready var slot3: TextureRect = get_node("Slots/Slot3/Gem")
onready var slot1Default = preload("res://Assets/HUD/staff.png")
onready var slot2Default = preload("res://Assets/HUD/tower.png")
onready var score_label: Label = get_node("Score")

var gem_id
var slot1Gem_id
var slot2Gem_id
var slot3Gem_id
var buffTower = 0

enum types {Fire, Water, Earth, Air}
var orbs_collected = []
var diff_types = 4
var diff_sizes = 4
var mouse_over = false
var score = 0
var all_gems = 0
var time = 0

func _ready():
	for x in diff_types:
		orbs_collected.append([])
		for y in range(diff_sizes):
			orbs_collected[x].append(0)
			gems.add_item(str(orbs_collected[x][y]), gems_paths[y])
			var idx = x * diff_sizes + y
			match x:
				0:
					gems.set_item_icon_modulate(idx, "#ba0b04")
				1:
					gems.set_item_icon_modulate(idx, "#09c3db")
				2:
					gems.set_item_icon_modulate(idx, "#806043")
				3:
					gems.set_item_icon_modulate(idx, "#a6e7ff")

func _physics_process(delta: float) -> void:
	time += delta
	var val = slot1.get_node("Bar").value
	if val > 0:
		slot1.get_node("Bar").set_value(val - 0.1)
	else:
		if slot1.texture != slot1Default:
			slot1.texture = slot1Default
			slot1.modulate = "#ffffff"
			slot1.get_node("Bar").set_value(0)
			player.update_staff(-1)
	
	if buffTower > 0:
		buffTower -= delta
		slot2.get_node("Bar").set_value(buffTower)
	elif buffTower < 0:
		buffTower = 0
		slot2.texture = slot2Default
		slot2.modulate = "#ffffff"
		slot2.get_node("Bar").set_value(0)
		player.update_tower(-1)
	
	score = int(time) + all_gems
	score_label.set_text(str(tr("SCORE"), score))

func get_orb(value, type) -> void:
	all_gems += value
	orbs_collected[type][0] += value
	gems.set_item_text((type * diff_sizes), str(orbs_collected[type][0]))
	while orbs_collected[type][0] >= 10:
		orbs_collected[type][0] -= 10
		orbs_collected[type][1] += 1
		gems.set_item_text((type * diff_sizes), str(orbs_collected[type][0]))
		gems.set_item_text((type * diff_sizes + 1), str(orbs_collected[type][1]))
		while orbs_collected[type][1] >= 10:
			orbs_collected[type][1] -= 10
			orbs_collected[type][2] += 1
			gems.set_item_text((type * diff_sizes + 1), str(orbs_collected[type][1]))
			gems.set_item_text((type * diff_sizes + 2), str(orbs_collected[type][2]))
			while orbs_collected[type][2] >= 10:
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
						slot1.texture = gems_paths[gem_id % diff_sizes]
						slot1.modulate = choosedGem.modulate
						slot1Gem_id = gem_id
						slot1.get_node("Bar").set_value(100)
						player.update_staff(gem_id)
					elif slot == 2:
						slot2.texture = gems_paths[gem_id % diff_sizes]
						slot2.modulate = choosedGem.modulate
						slot2Gem_id = gem_id
						buffTower = 10 + (gem_id % diff_sizes) * 10
						slot2.get_node("Bar").set_value(buffTower)
						slot2.get_node("Bar").set_max(buffTower)
						player.update_tower(gem_id)
					elif slot == 3:
						slot3.texture = gems_paths[gem_id % diff_sizes]
						slot3.modulate = choosedGem.modulate
						slot3Gem_id = gem_id
						slot3.get_node("Bar").set_value(100)
						level.update_strength(gem_id)
					orbs_collected[int(gem_id / diff_sizes)][(gem_id % diff_sizes)] -= 1
					gems.set_item_text(gem_id, str(orbs_collected[int(gem_id / diff_sizes)][(gem_id % diff_sizes)]))
					choosedGem.texture = null
	choosedGem.set_position(get_viewport().get_mouse_position())

func slot_clicked(pos: Vector2) -> int:
	var x_area = Vector2(1820, 1884)
	var y_area1 = Vector2(30, 113)
	var y_area2 = Vector2(138, 221)
	var y_area3 = Vector2(246, 329)
	if x_area.x <= pos.x and pos.x <= x_area.y:
		if y_area1.x <= pos.y and pos.y <= y_area1.y:
			return 1
		elif y_area2.x <= pos.y and pos.y <= y_area2.y:
			return 2
		if y_area3.x <= pos.y and pos.y <= y_area3.y:
			return 3
	return 0

func _on_Gems_selected(index):
	var type = int(index / diff_sizes)
	var size = index % diff_sizes
	if orbs_collected[type][size] != 0:
		choosedGem.texture = gems_paths[size]
		match type:
			0:
				choosedGem.modulate = "#ba0b04"
			1:
				choosedGem.modulate = "#09c3db"
			2:
				choosedGem.modulate = "#806043"
			3:
				choosedGem.modulate = "#a6e7ff"
		gem_id = index
